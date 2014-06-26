import org.xml.sax.SAXException

/**
 * Get the metadata of the pid.
 * If found, see if it is equal or different from the access status.
 */

final String url = args[0]

def xml = null
try {
    xml = new XmlSlurper().parse(url)
} catch (SAXException e) {
    // Assume a file not found. Not correctly displaying here.
    println('404')
    System.exit(0)
} catch (IOException e) {
     // Assume network problem.
    println(e)
    System.exit(1)
}

println(xml?.'**'?.find { it.name() == 'access' }?.text() ?: '404')