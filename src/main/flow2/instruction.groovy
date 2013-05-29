import groovy.xml.StreamingMarkupBuilder
import java.security.MessageDigest

class SorInstruction {

    private def orAttributes
    def files = 0
    private def mimeRepository = [:]
    private MessageDigest digest = MessageDigest.getInstance("MD5")

    public SorInstruction(def args) {
        orAttributes = args
        println("Loaded instruction class with arguments:")
        println(orAttributes)

	def p = System.getenv()['SORIMPORT_HOME'] ?: "."
        def file = new File(p + "/src/main/global/contenttype.txt")
        assert file.exists()
        file.eachLine {
            final String[] split = it.split(",")
            if (!mimeRepository.containsKey(split[0])) mimeRepository.put(split[0], split[1])
        }
    }

    void start() {

        def file = new File(orAttributes.fileSet, "instruction.xml")
        def writer = file.newWriter('UTF-8')
        def builder = new StreamingMarkupBuilder()
        builder.setEncoding("utf-8")
        builder.setUseDoubleQuotes(true)

        writer << builder.bind {
            mkp.xmlDeclaration()
            comment << 'Instruction produced on ' + new Date().toGMTString()
            instruction(orAttributes) {
                def folder = new File(orAttributes.fileSet)
                getFolders(folder, "/" + folder.name, out)
            }
        }
        writer.close()

        if (files == 0) file.delete()
    }

    private def getFolders(File folder, def location, def out) {
        if (folder.name[0] != '.') {
            for (File file : folder.listFiles()) {
                if (file.isDirectory()) {
                    getFolders(file, location + "/" + file.name, out)
                } else {
                    out << writeFile(file, location)
                }
            }
        }
    }

    private def writeFile(File f, def folder) {

        if (f.name.equals("instruction.xml")) return

        int i = f.name.lastIndexOf('.')
        def extension = (i == -1 || i == f.name.length() - 1) ? null : f.name.substring(i + 1)
        def _contentType = mimeRepository[extension] ?: "application/octet-stream"
        def _md5 = generateMD5(f)

        files++
        String _location = folder + "/" + f.name

        String _pid = f.name.replaceFirst(~/\.[^\.]+$/, '') // we make the PID the file name
        assert _pid
        _pid = orAttributes.na + "/" + _pid

        return {
            stagingfile {
                pid _pid
                location _location
                contentType _contentType
                md5 _md5
            }
        }
    }

    // taken from http://snipplr.com/view/8308/
    private def generateMD5(final file) {
        Date start = new Date()
        digest.reset()
        file.withInputStream() {is ->
            byte[] buffer = new byte[8192]
            int read
            while ((read = is.read(buffer)) > 0) {
                digest.update(buffer, 0, read);
            }
        }
        byte[] md5sum = digest.digest()
        BigInteger bigInt = new BigInteger(1, md5sum)
        def md5 = bigInt.toString(16)
        Date end = new Date()
        long diff = end.getTime() - start.getTime()
        println(file.name + "\t" + md5 + "\t" + file.length() + "\t" + diff / 1000)
        md5
    }
}


def arguments = [xmlns: 'http://objectrepository.org/instruction/1.0/']
for (int i = 0; i < args.length; i++) {
    if (args[i][0] == '-') {
        arguments.put(args[i].substring(1), args[i + 1])
    }
}

["fileSet", "na"].each {
    assert arguments[it], "Need required argument -$it [value]"
}

def instruction = new SorInstruction(arguments)
println("Start...")
instruction.start()
println("Done. Processed " + instruction.files + " files.")