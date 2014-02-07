/*
Check if the argument is a datestamp in the format: YYYY-MM-DD
If invalid, we will exit cleanly.
 */

def fileSet = new File(args[0])

try {
    new Date().parse("yyyy-mm-dd", fileSet.name)
} catch (Exception e) {
    println(e)
    System.exit(1)
}

System.exit(0)