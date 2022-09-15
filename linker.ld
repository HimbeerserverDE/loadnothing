MEMORY {
	RAM : org = 0x7e00, l = 12K
}

SECTIONS {
	. = 0x7e00;
	.text :
	{
		*(.text)
	} > RAM
}
