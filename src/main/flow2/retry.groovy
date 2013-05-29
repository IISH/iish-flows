/**
 * retry.groovy
 *
 * We scan through the log to find a faulty file and offer that one for a reupload
 */

assert args.size() == 2, "Need a two command line argument that is the log and the second the WINSCP script"
def log = new File(args[0])
assert log.isFile(), "There is no such file " + args[0]

def retry = new File(args[1])
int count = 0
String file
log.eachLine {

    String line = (it.length() > 26) ? it.substring(26) : it
    // Get the file: File, for example:
    // . 2012-06-27 01:23:10.112 File: "masters/usercopies/30051000165578.JPG"
    if (line.startsWith("File: ")) file = line.substring(6)
    if (line.startsWith("Error transferring file")) {
        println("Re-put " + file)
        retry.append("put " + file + " ./" + file.replace("\\", "/") + "\r\n")
	count++
    }
}

retry.append("close\r\n" +
        "exit\r\n")

println("Retry count: " + count)
if ( count == 0 ) {
	retry.delete()
}