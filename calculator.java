public class calculator {

    public static void main(String[] args) {
        int a = 20;
        int b = 5;

        multiply(a, b);
        divide(a, b);
    }

    public static void multiply(int x, int y) {
        System.out.println("Multiplication: " + (x * y));
    }

    public static void divide(int x, int y) {
        if (y != 0) {
            System.out.println("Division: " + (x / y));
        } else {
            System.out.println("Division by zero is not allowed");
        }
    }
}


line 1
line 2
    line3 
