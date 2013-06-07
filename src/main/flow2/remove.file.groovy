import javax.xml.stream.XMLInputFactory
import javax.xml.stream.XMLStreamReader

assert args.size() == 1, "Expect one argument: full path of the instruction file"

File instruction = new File(args[0])
assert instruction.exists()

def good = []
def bad = []
readInstruction(instruction, good, bad)

println(bad.size() + " mislukt:")
bad.each {
	println(it)
}

println();
println(good.size() + " gelukt:")
good.each {
	println(it)
}

def readInstruction(File instruction, def good, def bad) {

    final XMLInputFactory xif = XMLInputFactory.newInstance()
    final XMLStreamReader xsr = xif.createXMLStreamReader(instruction.newReader())
    while (xsr.hasNext()) {
        int next = xsr?.next()
        if (next == XMLStreamReader.START_ELEMENT && xsr.localName.contains("stagingfile")) {
	    // example <pid>10622/30000000000000</pid><location>/2013-02-12/30051/30000000000000.tif</location><contentType>text/plain</contentType><md5>b0fcc7b9968168c4e31b90ebceb52932</md5>
	    def l = [:]
	    ['pid', 'location', 'contentType', 'md5'].each {
			xsr.next()
			l[it]=xsr.getElementText()
			assert l[it], "Must have a $it key with a value that is not null"
	    }
	    if (inSor(l)) {
			new File(instruction.parentFile.parentFile, l.location).delete()
			good << "http://hdl.handle.net/$l.pid?locatt=view:level2"
		}
	    else {
			bad << "$l.pid met md5 $md5"
            }
	}
    }
}

def inSor(def l) {
	String url = "http://disseminate.objectrepository.org/metadata/$l.pid?accept=text/xml"
	def orfiles = new XmlSlurper().parse(url).declareNamespace(ns: 'http://objectrepository.org/orfiles/1.0/')
	def md5 = orfiles.'ns:orfile'.'ns:master'.'ns:md5'
	compare( md5.text(), l.md5 )
}

boolean compare(String md5_A, String md5_B) {

        if (md5_A == null || md5_B == null) return false

        final BigInteger md5_alfa
        final BigInteger md5_beta

        try {
            md5_alfa = new BigInteger(md5_A, 16)
            md5_beta = new BigInteger(md5_B, 16)
        } catch (NumberFormatException e) {
            println(e.message)
            return false
        }

        md5_beta.compareTo(md5_alfa) == 0
}