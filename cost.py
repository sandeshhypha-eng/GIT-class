#!/usr/bin/env python3
"""
AWS Daily Cost Explorer Report

Purpose:
- Fetch total AWS cost and per-service cost for yesterday and the day before.
- Compute percentage changes in costs.
- Send a nicely formatted message to Discord.
- Currency is INR by default (can be changed).

Notes for beginners:
- Boto3 is the official AWS SDK for Python.
- Cost Explorer API gives your actual AWS spend.
- Discord webhook allows sending messages to a Discord channel programmatically.
"""

import os             # Used to access environment variables
import sys            # Used to exit the program if needed
import boto3          # AWS SDK for Python
import datetime       # Work with dates
import requests       # Send HTTP requests (Discord webhook)

# === CONFIG ===

# Discord webhook URL stored as environment variable for security
DISCORD_WEBHOOK = os.environ.get("DISCORD_WEBHOOK")

# Currency to display costs in. Default is INR.
BILLING_CURRENCY = os.environ.get("BILLING_CURRENCY", "INR").upper()

# List of top 10 AWS services to track
TOP_SERVICES = [
    "AmazonEC2", "AmazonEBS", "AWSElasticLoadBalancing", "AmazonEKS",
    "AmazonS3", "AmazonRDS", "AWSLambda", "AmazonDynamoDB",
    "AmazonCloudWatch", "AmazonVPC"
]

# Friendly names for each service to make Discord message readable
SERVICE_FRIENDLY = {
    "AmazonEC2": "EC2",
    "AmazonEBS": "EBS",
    "AWSElasticLoadBalancing": "ELB",
    "AmazonEKS": "EKS",
    "AmazonS3": "S3",
    "AmazonRDS": "RDS",
    "AWSLambda": "Lambda",
    "AmazonDynamoDB": "DynamoDB",
    "AmazonCloudWatch": "CloudWatch",
    "AmazonVPC": "VPC/NAT Gateway"
}

# === Helper Functions ===

def iso_date(dt):
    """
    Convert a datetime.date object to a string in YYYY-MM-DD format
    AWS Cost Explorer API requires dates in this string format.
    Example: 2025-10-25
    """
    return dt.strftime("%Y-%m-%d")

def pct_change(old, new):
    """
    Calculate percentage change from old value to new value.
    Returns None if any value is missing.
    Handles the special case when old value is 0.
    """
    if old is None or new is None:
        return None
    if old == 0:
        return 0 if new == 0 else None
    return ((new - old) / old) * 100.0

def fetch_cost(ce_client, start_date, end_date, service=None):
    """
    Fetch the cost from AWS Cost Explorer.
    - ce_client: boto3 Cost Explorer client
    - start_date: YYYY-MM-DD (inclusive)
    - end_date: YYYY-MM-DD (exclusive)
    - service: optional AWS service name; if None, fetch total cost
    Returns the total unblended cost as a float, or None if error occurs.
    """
    try:
        # If service is specified, create a filter object for API
        filter_obj = {"Dimensions": {"Key": "SERVICE", "Values": [service]}} if service else None

        # Call AWS Cost Explorer API
        resp = ce_client.get_cost_and_usage(
            TimePeriod={"Start": start_date, "End": end_date},
            Granularity="DAILY",       # We want daily cost
            Metrics=["UnblendedCost"],  # Metric to fetch
            Filter=filter_obj           # Apply service filter if provided
        )

        results = resp.get("ResultsByTime", [])
        if not results:
            return None

        # Sum the cost over the period (usually just 1 day)
        total = 0.0
        for r in results:
            amt = r.get("Total", {}).get("UnblendedCost", {}).get("Amount")
            total += float(amt) if amt else 0.0

        return total
    except Exception as e:
        print(f"Error fetching cost for {service or 'TOTAL'}: {e}")
        return None

def send_discord(msg):
    """
    Send a message to Discord channel via webhook.
    - msg: string message content
    """
    if not DISCORD_WEBHOOK:
        print("DISCORD_WEBHOOK not set. Skipping Discord notification.")
        return
    payload = {"content": msg}  # Discord expects JSON with 'content'
    try:
        r = requests.post(DISCORD_WEBHOOK, json=payload, timeout=15)
        if r.status_code // 100 == 2:
            print("Discord message sent successfully.")
        else:
            print(f"Discord send failed: {r.status_code} {r.text}")
    except Exception as e:
        print("Discord send exception:", e)

# === Main Function ===

def main():
    """
    Main script execution.
    - Fetch total AWS cost
    - Fetch per-service cost
    - Calculate % changes
    - Build a readable Discord message
    - Send it
    """
    # Ensure Discord webhook is configured
    if not DISCORD_WEBHOOK:
        print("DISCORD_WEBHOOK not configured. Exiting.")
        sys.exit(1)

    # Initialize AWS session (uses credentials from environment/GitHub Actions)
    session = boto3.Session()
    # Create Cost Explorer client
    ce = session.client("ce", region_name="us-east-1")  # CE API only in us-east-1

    # Determine dates for yesterday and day-before-yesterday
    today = datetime.datetime.utcnow().date()  # UTC today
    y = today - datetime.timedelta(days=1)      # yesterday
    y2 = today - datetime.timedelta(days=2)     # day before yesterday
    y_str = iso_date(y)
    y2_str = iso_date(y2)

    # --- Fetch total AWS cost ---
    cost_y = fetch_cost(ce, y_str, iso_date(y + datetime.timedelta(days=1)))
    cost_y2 = fetch_cost(ce, y2_str, iso_date(y2 + datetime.timedelta(days=1)))
    total_pct = pct_change(cost_y2, cost_y) if (cost_y is not None and cost_y2 is not None) else None

    # --- Fetch per-service cost ---
    service_costs = {}
    for svc in TOP_SERVICES:
        c_y = fetch_cost(ce, y_str, iso_date(y + datetime.timedelta(days=1)), svc)
        c_y2 = fetch_cost(ce, y2_str, iso_date(y2 + datetime.timedelta(days=1)), svc)
        pct = pct_change(c_y2, c_y) if (c_y is not None and c_y2 is not None) else None
        service_costs[svc] = {"y": c_y, "y2": c_y2, "pct": pct}

    # --- Build Discord message ---
    msg_lines = []
    msg_lines.append(f"📌 **Daily AWS Cost Report ({BILLING_CURRENCY})** — {y_str} vs {y2_str}\n")

    # Total cost section
    if total_pct is not None:
        sign = "+" if total_pct >= 0 else ""
        msg_lines.append(f"💰 **Total Cost Change:** {sign}{total_pct:.2f}%")
        msg_lines.append(f"• Yesterday: {BILLING_CURRENCY} {cost_y:.2f}")
        msg_lines.append(f"• Day Before: {BILLING_CURRENCY} {cost_y2:.2f}\n")
    else:
        msg_lines.append("💰 **Total Cost Change:** No data available\n")

    # Per-service section
    msg_lines.append("📌 **Top 10 Services:**")
    for svc in TOP_SERVICES:
        data = service_costs[svc]
        if data["y"] is None or data["y2"] is None:
            msg_lines.append(f"• {SERVICE_FRIENDLY[svc]} — No data")
            continue
        sign = "+" if data["pct"] is not None and data["pct"] >= 0 else ""
        msg_lines.append(f"• {SERVICE_FRIENDLY[svc]} — {BILLING_CURRENCY} {data['y']:.2f} ({sign}{data['pct']:.2f}%)")

    # Join all lines into a single message string
    msg = "\n".join(msg_lines)
    # Send the message to Discord
    send_discord(msg)

# Entry point
if __name__ == "__main__":
    main()


line 1
line2
