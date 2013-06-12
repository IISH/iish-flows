/**
 * BuildUDFImage.groovy
 *
 * Creates an UDF 1.02 iso image
 *
 * Usage: BuildUDFImage.groovy [source folder] [target file] [an identifier or label]
 */

import com.github.stephenc.javaisotools.udflib.UDFImageBuilder
import com.github.stephenc.javaisotools.udflib.UDFRevision

assert args.length == 3
File fileSource = new File(args[0])
String fileTarget = args[1]
String identifier = args[2]
println("Building iso UDF 1.02 for " + identifier)

long startTime = Calendar.getInstance().getTimeInMillis();

try {
    def myUDFImageBuilder = new UDFImageBuilder();
    def children = fileSource.listFiles()
    for (int i = 0; i < children.length; ++i) {
        myUDFImageBuilder.addFileToRootDirectory(children[i])
    }

    myUDFImageBuilder.setImageIdentifier(identifier)

    myUDFImageBuilder.writeImage(fileTarget, UDFRevision.Revision102)
}
catch (Exception myException) {
    System.out.println(myException.toString());
    myException.printStackTrace();
}

println("Run-Time: " + (Calendar.getInstance().getTimeInMillis() - startTime) + " Milliseconds")