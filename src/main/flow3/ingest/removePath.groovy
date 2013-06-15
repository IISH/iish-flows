/**
 * removePath
 *
 * Remove all references that come before the second argument args[1]
 */

def fileSet = args[1]
String f = new File('/' + fileSet[0]+':' + fileSet[2..-1].replaceAll("\\\\", "/")).toURI().toString()
def replace = [fileSet.replaceAll("\\\\", "\\\\\\\\"), f]

def tmp = new File(args[0] + ".tmp")

new File(args[0]).eachLine {

   replace.each { r ->
       it=it.replaceAll(r, '')
   }
    tmp.write(it)
    tmp.write("\n")
}

tmp.renameTo(args[0])