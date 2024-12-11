/* re-write from ELF.H (only for MIPS-PS2 */

/* Type for a 16-bit quantity.	*/
typedef unsigned short Elf32_Half;

/* Types for signed and unsigned 32-bit quantities.  */
typedef unsigned long Elf32_Word;
typedef 	 long Elf32_Sword;

/* Types for signed and unsigned 64-bit quantities.  */
// typedef unsigned double Elf32_Xword;
// typedef	    double Elf32_Sxword;

/* Type of addresses.  */
typedef unsigned long Elf32_Addr;

/* Type of file offsets.  */
typedef unsigned long Elf32_Off;

/* Type for section indices, which are 16-bit quantities.  */
typedef unsigned short int Elf32_Section;

/* Type of symbol indices.  */
typedef unsigned long Elf32_Symndx;


/* The ELF file header.  This appears at the start of every ELF file.  */
#define EI_NIDENT (16)
typedef struct
{
  unsigned char e_ident[EI_NIDENT];	/* Magic number and other info */
  Elf32_Half	e_type; 		/* Object file type */
  Elf32_Half	e_machine;		/* Architecture */
  Elf32_Word	e_version;		/* Object file version */
  Elf32_Addr	e_entry;		/* Entry point virtual address */
  Elf32_Off	    e_phoff;		/* Program header table file offset */
  Elf32_Off	    e_shoff;		/* Section header table file offset */
  Elf32_Word	e_flags;		/* Processor-specific flags */
  Elf32_Half	e_ehsize;		/* ELF header size in bytes */
  Elf32_Half	e_phentsize;	/* Program header table entry size */
  Elf32_Half	e_phnum;		/* Program header table entry count */
  Elf32_Half	e_shentsize;	/* Section header table entry size */
  Elf32_Half	e_shnum;		/* Section header table entry count */
  Elf32_Half	e_shstrndx;		/* Section header string table index */
} Elf32_Ehdr;


/* Program segment header.  */
typedef struct
{
  Elf32_Word	p_type; 		/* Segment type */
  Elf32_Off	    p_offset;		/* Segment file offset */
  Elf32_Addr	p_vaddr;		/* Segment virtual address */
  Elf32_Addr	p_paddr;		/* Segment physical address */
  Elf32_Word	p_filesz;		/* Segment size in file */
  Elf32_Word	p_memsz;		/* Segment size in memory */
  Elf32_Word	p_flags;		/* Segment flags */
  Elf32_Word	p_align;		/* Segment alignment */
} Elf32_Phdr;

/* Section header.  */
typedef struct
{
  Elf32_Word	sh_name;		/* Section name (string tbl index) */
  Elf32_Word	sh_type;		/* Section type (cf. Line 103) */
  Elf32_Word	sh_flags;		/* Section flags */
  Elf32_Addr	sh_addr;		/* Section virtual addr at execution */
  Elf32_Off	    sh_offset;		/* Section file offset */
  Elf32_Word	sh_size;		/* Section size in bytes */
  Elf32_Word	sh_link;		/* Link to another section */
  Elf32_Word	sh_info;		/* Additional section information */
  Elf32_Word	sh_addralign;		/* Section alignment */
  Elf32_Word	sh_entsize;		/* Entry size if section holds table */
} Elf32_Shdr;

/* Symbol table entry.	*/
typedef struct
{
  Elf32_Word	st_name;		/* Symbol name (string tbl index) */
  Elf32_Addr	st_value;		/* Symbol value */
  Elf32_Word	st_size;		/* Symbol size */
  unsigned char st_info;		/* Symbol type and binding */
  unsigned char st_other;		/* No defined meaning, 0 */
  Elf32_Section st_shndx;		/* Section index */
} Elf32_Sym;

/* Entry found in sections of type SHT_MIPS_REGINFO.  */
typedef struct
{
  Elf32_Word	ri_gprmask;		    /* General registers used */
  Elf32_Word	ri_cprmask[4];		/* Coprocessor registers used */
  Elf32_Sword	ri_gp_value;		/* $gp register value */
} Elf32_RegInfo;

/* Legal values for sh_type (section type).  */
#define NOFUNC	0	        // 此 Section 無特殊功能
#define SHT_NULL	0		/* Section header table entry unused */
#define SHT_PROGBITS	1	 /* Program data */
#define SHT_SYMTAB	2		/* Symbol table */
#define SHT_STRTAB	3		/* String table */
#define SHT_RELA	4		/* Relocation entries with addends */
#define SHT_HASH	5		/* Symbol hash table */
#define SHT_DYNAMIC	6		/* Dynamic linking information */
#define SHT_NOTE	7		/* Notes */
#define SHT_NOBITS	8		/* Program space with no data (bss) */
#define SHT_REL 	9		/* Relocation entries, no addends */
#define SHT_SHLIB	10		/* Reserved */
#define SHT_DYNSYM	11		/* Dynamic linker symbol table */
#define SHT_NUM 	12		/* Number of defined types.  */
#define SHT_LIBLIST 0x7000	// Shared objects used in link
#define SHT_CONFLT  0x7002	// Conflicting symbols
#define SHT_GPTAB   0x7003	// Global data area sizes
#define SHT_UCODE   0x7004	// Reserved for SGI/MIPS compilers
#define SHT_DEBUG   0x7005	// MIPS ECOFF debugging information
#define SHT_REGINFO 0x7006	// 要看暫存器訊息
#define SHT_OPTIONS 0x700D	// Miscellaneous options
#define SHT_DWARF   0x701E	// DWARF debugging information
#define SHT_EVENTS  0x7021	// Event section
#define SHT_IOPMOD  0x7080	// 模組相關資訊

// relocation table 有 with/without addend 值的分別

/* Relocation table entry without addend (in section of type SHT_REL).	*/
typedef struct
{
  Elf32_Addr	r_offset;		/* Address */
  Elf32_Word	r_info; 		/* Relocation type and symbol index */
} Elf32_Rel;


/* Relocation table entry with addend (in section of type SHT_RELA).  */
typedef struct
{
  Elf32_Addr	r_offset;		/* Address */
  Elf32_Word	r_info; 		/* Relocation type and symbol index */
  Elf32_Sword	r_addend;		/* Addend */
} Elf32_Rela;

/* How to extract and insert information held in the r_info field.  */
#define ELF32_R_SYM(val)		((val) >> 8)
#define ELF32_R_TYPE(val)		((val) & 0xff)
#define ELF32_R_INFO(sym, type) 	(((sym) << 8) + ((type) & 0xff))

/* MIPS relocs.  */
#define R_MIPS_NONE	0		/* No reloc */
#define R_MIPS_16	1		/* Direct 16 bit */
#define R_MIPS_32	2		/* Direct 32 bit */
#define R_MIPS_REL32	3	/* PC relative 32 bit */
#define R_MIPS_26	4		/* Direct 26 bit shifted */
#define R_MIPS_HI16	5		/* High 16 bit */
#define R_MIPS_LO16	6		/* Low 16 bit */
#define R_MIPS_GPREL16	7	/* GP relative 16 bit */
#define R_MIPS_LITERAL	8	/* 16 bit literal entry */
#define R_MIPS_GOT16	9	/* 16 bit GOT entry */
#define R_MIPS_PC16	10		/* PC relative 16 bit */
#define R_MIPS_CALL16	11	/* 16 bit GOT entry for function */
#define R_MIPS_GPREL32	12	/* GP relative 32 bit */

// 模組相關資訊 (我自定)
typedef struct
{
  Elf32_Addr	i_dataVA;	// .data section 擺放的 virtual address
  Elf32_Addr	i_EntryPC;	// 程式的 Entry Point
  Elf32_Word	i_GP;		// Global Pointer (gp) 暫存器的初值
  Elf32_Addr	i_rodata;	// .data section (read only) 擺放的 virtual address
  Elf32_Word	i_dataSize;	// .rodata 加上 .data 此二區段的大小總合
  Elf32_Word	i_seg1add;	// Segment No.1 應多借多少 bytes 的大小
  Elf32_Half	i_unk;		// 大多為 01 01 或 00 00 (未知)
  char	modName[23];		// 放此模組的全名
} Elf32_Iop;

