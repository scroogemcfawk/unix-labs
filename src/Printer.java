import java.util.Arrays;

public class Printer
{
    static void print(String[] args, String sep, String end)
    {
        for (var i : Arrays.stream(args).limit(args.length - 1).toList()) {
            System.out.print(i + sep);
        }
        System.out.print(args[args.length - 1] + end);
    }
}
