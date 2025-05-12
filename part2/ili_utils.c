#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
	asm volatile("sidt %0;"
			:"=m"(*idtr)
			:
			:
			);
}

void my_load_idt(struct desc_ptr *idtr) {
	asm volatile("lidt %0;"
		        :
		        :"m"(*idtr)
		        :
		        );
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
	gate->offset_high = addr >> 32;
	gate->offset_middle = addr >> 16;
	gate->offset_low = addr;
}

unsigned long my_get_gate_offset(gate_desc *gate) {
	unsigned long addres = 0;
	unsigned long high_offset = (unsigned long) gate->offset_high;
	unsigned int middle_offset = (unsigned int) gate->offset_middle;
	unsigned short low_offset = (unsigned short) gate->offset_low;
	high_offset = high_offset << 32;
	middle_offset = middle_offset << 16;
	low_offset  = low_offset <<0;
	addres = high_offset + middle_offset + low_offset;

	return addres;
}
