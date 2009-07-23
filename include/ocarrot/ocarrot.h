#ifndef OCARROT_OCARROT_H_GUARD
#define OCARROT_OCARROT_H_GUARD

#include "pmc_caml_value.h"
#include "pmc_caml_block.h"

#define OCarrot_Value_is_boxed PObj_private0_FLAG
#define ocarrot_words(x) ((x + PTR_SIZE - 1) / PTR_SIZE)

#define No_scan_tag 255
#define Closure_tag (No_scan_tag + 1)
#define String_tag (No_scan_tag + 2)
#define Double_tag (No_scan_tag + 3)
#define Double_array_tag (No_scan_tag + 4)
#define Abstract_tag (No_scan_tag + 5)
#define Custom_tag (No_scan_tag + 6)

#endif /* OCARROT_OCARROT_H_GUARD */
