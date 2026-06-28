#bin/sh
intallhh



      - name: SonarCloud Scan
        uses: SonarSource/sonarqube-scan-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        with:
          projectBaseDir: CalculatorProject
          args: >
            -Dsonar.organization=${{ secrets.SONAR_ORGANIZATION }}
            -Dsonar.projectKey=${{ secrets.SONAR_PROJECT_KEY }}
            -Dsonar.projectName=${{ secrets.SONAR_PROJECT_NAME }}
            -Dsonar.host.url=https://sonarcloud.io
            