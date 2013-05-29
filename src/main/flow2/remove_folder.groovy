File folder = new File(args[0])
if ( dropFolder(folder, false) == 0) {
	println("Ok to delete")
	dropFolder(folder, true)
        new File(folder, "instruction.xml").delete()
	folder.delete()
}

private def dropFolder(File folder, boolean delete) {

    println( folder.name )
    int count = 0
    for (File file : folder.listFiles()) {
        if (file.isDirectory()) {
		count+=dropFolder(file, delete)
		if ( delete ) file.delete()
	} else {
	println("=".multiply(100))
		println(file.name)
		if ( file.name != "instruction.xml") count++
	}
    }
    count
}