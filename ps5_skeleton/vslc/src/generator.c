#include "vslc.h"

// This header defines a bunch of macros we can use to emit assembly to stdout
#include "emit.h"

// In the System V calling convention, the first 6 integer parameters are passed in registers
#define NUM_REGISTER_PARAMS 6
static const char *REGISTER_PARAMS[6] = {RDI, RSI, RDX, RCX, R8, R9};

// Takes in a symbol of type SYMBOL_FUNCTION, and returns how many parameters the function takes
#define FUNC_PARAM_COUNT(func) ((func)->node->children[1]->n_children)
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) > (b) ? (b) : (a))

extern char **string_list;
extern size_t string_list_len;

static void generate_stringtable ( void );
static void generate_global_variables ( void );
static void generate_function ( symbol_t *function );
static void generate_expression ( node_t *expression );
static void generate_statement ( node_t *node );
static void generate_main ( symbol_t *first );

/* Entry point for code generation */
void generate_program ( void )
{
    generate_stringtable ( );
    generate_global_variables ( );

    // This directive announces that the following assembly belongs to the executable code .text section.
    DIRECTIVE ( ".text" );
    // TODO: (Part of 2.3)
    // For each function in global_symbols, generate it using generate_function ()
    symbol_t *main = 0;
    for (size_t i = 0; i < global_symbols->n_symbols; i++)
    {
        symbol_t *sym = global_symbols->symbols[i];
        if ( sym->type == SYMBOL_FUNCTION ){
            main = !main ? sym : main;
            generate_function(sym);
        }
    }
    
    // TODO: (Also part of 2.3)
    // In VSL, the topmost function in a program is its entry point.
    // We want to be able to take parameters from the command line,
    // and have them be sent into the entry point function.
    //
    // Due to the fact that parameters are all passed as strings,
    // and passed as the (argc, argv)-pair, we need to make a wrapper for our entry function.
    // This wrapper handles string -> int64_t conversion, and is already implemented.
    // call generate_main ( <entry point function symbol> );
    generate_main(main);
}

/* Prints one .asciz entry for each string in the global string_list */
static void generate_stringtable ( void )
{
    // This section is where read-only string data is stored
    // It is called .rodata on Linux, and "__TEXT, __cstring" on macOS
    DIRECTIVE ( ".section %s", ASM_STRING_SECTION );

    // These strings are used by printf
    DIRECTIVE ( "intout: .asciz \"%s\"", "%ld" );
    DIRECTIVE ( "strout: .asciz \"%s\"", "%s" );
    // This string is used by the entry point-wrapper
    DIRECTIVE ( "errout: .asciz \"%s\"", "Wrong number of arguments" );

    // TODO 2.1: Print all strings in the program here, with labels you can refer to later

    for (size_t i = 0; i < string_list_len; i++)
    {
        DIRECTIVE ( "string%ld: .asciz %s", i, string_list[i] );
    }
}

/* Prints .zero entries in the .bss section to allocate room for global variables and arrays */
static void generate_global_variables ( void )
{
    // This section is where zero-initialized global variables lives
    // It is called .bss on linux, and "__DATA, __bss" on macOS
    DIRECTIVE ( ".section %s", ASM_BSS_SECTION );
    DIRECTIVE ( ".align 8" );
    extern symbol_table_t *global_symbols;
    
    // TODO 2.2: Fill this section with all global variables and global arrays
    // Give each a label you can find later, and the appropriate size.
    // Regular variables are 8 bytes, while arrays are 8 bytes per element.
    // Remember to mangle the name in some way, to avoid collisions if a variable is called e.g. "main"

    for (size_t i = 0; i < global_symbols->n_symbols; i++)
    {   
        symbol_t *sym = global_symbols->symbols[i];
        if( sym->type == SYMBOL_GLOBAL_VAR )
            DIRECTIVE( ".%s: .zero 8", sym->name);
        
        else if ( sym->type == SYMBOL_GLOBAL_ARRAY )
            DIRECTIVE(".%s: .zero %ld", sym->name, (*(long*)sym->node->children[1]->data) * 8);
    }

    // For example to set aside 16 bytes and label it .myBytes:
    // DIRECTIVE ( ".myBytes: .zero 16" )
}

/* Global variable you can use to make the functon currently being generated accessible from anywhere */
static symbol_t *current_function;

/* Prints the entry point. preamble, statements and epilouge of the given function */
static void generate_function ( symbol_t *function )
{
    // TODO: 2.3

    // TODO: 2.3.1 Do the prologue, including call frame building and parameter pushing
    // Tip: use the definitions REGISTER_PARAMS and NUM_REGISTER_PARAMS at the top of this file
    DIRECTIVE( ".%s:", function->name );
    PUSHQ( RBP );
    MOVQ( RSP, RBP );
    for (size_t i = 0; i < NUM_REGISTER_PARAMS; i++)
    {
        PUSHQ( REGISTER_PARAMS[i] );
    }
    for (size_t i = 0; i < function->function_symtable->n_symbols; i++)
    {
        symbol_t *sym = function->function_symtable->symbols[i];
        if ( sym->type == SYMBOL_LOCAL_VAR )
            PUSHQ( "$0" );
    }
    
    
    // TODO: 2.4 the function body can be sent to generate_statement()
    current_function = function;
    generate_statement(function->node);

    
    // TODO: 2.3.2
    MOVQ("$0", RAX);
    LABEL(".epilogue_%s",function->name);
    MOVQ( RBP, RSP );
    POPQ( RBP );
    RET;
}

static void generate_function_call ( node_t *call )
{
    // TODO 2.4.3
    int n_params = call->children[1]->n_children;
    for (size_t i = 0; i < MIN(6,n_params); i++)
    {
        generate_expression(call->children[1]->children[i]);
        MOVQ(RAX, REGISTER_PARAMS[i]);
    }
    if (n_params > 6)
        for (size_t i = n_params - 1; i >= 6 ; i--)
        {
            generate_expression(call->children[1]->children[i]);
            PUSHQ(RAX);
        }
    
    EMIT("call .%s", (char *)call->children[0]->data);
    if (n_params > 6)
        for (size_t i = n_params - 1; i >= 6 ; i--)
        {
            POPQ(RCX);
        }
}

/* Generates code to evaluate the expression, and place the result in %rax */
static void generate_expression ( node_t *expression )
{
    // TODO: 2.4.1 Generate code for evaluating the given expression.
    printf("\t# Generating expression\n");
    switch (expression->type)
    {
    case NUMBER_DATA:
    {
        long number = *(long*)expression->data;
        EMIT("movq $%ld, %s", number, RAX);
        break;
    }

    case IDENTIFIER_DATA:
        switch (expression->symbol->type)
        {
        case SYMBOL_GLOBAL_VAR:
            EMIT("movq .%s(%s), %s", expression->symbol->name, RIP, RAX);
            break;
        case SYMBOL_LOCAL_VAR:
            EMIT("movq %d(%s), %s", -56 + (expression->symbol->sequence_number - FUNC_PARAM_COUNT(current_function)) * -8, RBP, RAX);
            break;
        case SYMBOL_PARAMETER:
        {
            int sequence_number = expression->symbol->sequence_number;
            int offset = sequence_number >= 6 ? 8*(sequence_number-4) : -8*(sequence_number+1);
            EMIT("movq %d(%s), %s", offset, RBP, RAX);
            break;
        }
        
        default:
            break;
        }
        break;

    case ARRAY_INDEXING:
        generate_expression(expression->children[1]);
        EMIT("leaq .%s(%s), %s", (char *)expression->children[0]->data, RIP, RCX);
        EMIT("leaq (%s, %s, 8), %s", RCX, RAX, RCX);
        EMIT("movq (%s), %s", RCX, RAX);
        break;

    case EXPRESSION:
        generate_expression(expression->children[0]);
        if (expression->n_children == 1 && strcmp(expression->data, "-") == 0)
        {
            NEGQ(RAX);
            break;
        }
        PUSHQ(RAX);
        generate_expression(expression->children[1]);
        POPQ(RCX);

        if (strcmp(expression->data, "+") == 0 )
            ADDQ(RCX, RAX);

        if (strcmp(expression->data, "-") == 0 )
        {
            PUSHQ(RCX);
            PUSHQ(RAX);
            POPQ(RCX);
            POPQ(RAX);
            SUBQ(RCX, RAX);
        }

        if (strcmp(expression->data, "*") == 0 )
            IMULQ(RCX, RAX);

        if (strcmp(expression->data, "/") == 0 )
        {
            MOVQ("$0",RDX);
            PUSHQ(RCX);
            PUSHQ(RAX);
            POPQ(RCX);
            POPQ(RAX);
            IDIVQ(RCX);
        }

        if (strcmp(expression->data, ">>") == 0 )
        {
            PUSHQ(RCX);
            PUSHQ(RAX);
            POPQ(RCX);
            POPQ(RAX);
            SAR("%cl",RAX);

        }

        if (strcmp(expression->data, "<<") == 0 )
        {
            PUSHQ(RCX);
            PUSHQ(RAX);
            POPQ(RCX);
            POPQ(RAX);
            SAL("%cl",RAX);
        }

        break;

    case FUNCTION_CALL:
        generate_function_call(expression);
        break;
    
    default:
        break;
    }


}

static void generate_assignment_statement ( node_t *statement )
{
    // TODO: 2.4.2
    // You can assign to both local variables, global variables and function parameters.
    // Use the IDENTIFIER_DATA's symbol to find out what kind of symbol you are assigning to.
    // The left hand side of an assignment statement may also be an ARRAY_INDEXING node.
    
    generate_expression(statement->children[1]);
    node_t *left = statement->children[0];

    if (left->type == ARRAY_INDEXING){        
        PUSHQ(RAX);
        generate_expression(left->children[1]);
        EMIT("leaq .%s(%s), %s", (char *)left->children[0]->data, RIP, RCX);
        EMIT("leaq (%s, %s, 8), %s", RCX, RAX, RCX);
        POPQ(RAX);
        EMIT("movq %s, (%s)", RAX, RCX);
        return;
    }

    switch (left->symbol->type)
    {
    case SYMBOL_GLOBAL_VAR:
        EMIT("movq %s, .%s(%s)",RAX, (char *)left->data, RIP);
        break;
    case SYMBOL_LOCAL_VAR:
        EMIT("movq %s, %d(%s)", RAX, -56 + (left->symbol->sequence_number - FUNC_PARAM_COUNT(current_function)) * -8, RBP);
        break;
    case SYMBOL_PARAMETER:
    {
        int sequence_number = left->symbol->sequence_number;
        int offset = sequence_number >= 6 ? 8*(sequence_number-4) : -8*(sequence_number+1);
        EMIT("movq %s, %d(%s)", RAX, offset, RBP);
        break;
    }
    
    default:
        break;
    }
    
    return;
}

static void generate_print_statement ( node_t *statement )
{
    // TODO: 2.4.4
    // Remember to call safe_printf instead of printf
    printf("\t# Print statement\n");
    for (size_t i = 0; i < statement->children[0]->n_children; i++)
    {
        node_t *child = statement->children[0]->children[i];
        printf("\t# Type of print item: %u\n", child->type);
        switch (child->type)
        {
        case STRING_LIST_REFERENCE:
        {
            EMIT("leaq string%ld(%s), %s",(long)child->data, RIP, REGISTER_PARAMS[1]);

            EMIT("leaq strout(%s), %s", RIP, REGISTER_PARAMS[0]);
            break;
        }
        
        default:
        {
            generate_expression(child);
            MOVQ(RAX, REGISTER_PARAMS[1]);
            EMIT("leaq intout(%s), %s", RIP, REGISTER_PARAMS[0]);
            break;
        }
        }
        
        EMIT("call safe_printf");
    }
    // newline
    MOVQ("$'\n'", REGISTER_PARAMS[0]);
    EMIT("call putchar");
    
}

static void generate_return_statement ( node_t *statement )
{
    // TODO: 2.4.5 Store the value in %rax and jump to the function epilogue
    generate_expression(statement->children[0]);
    EMIT("jmp .epilogue_%s", current_function->name);
}

/* Recursively generate the given statement node, and all sub-statements. */
static void generate_statement ( node_t *node )
{
    EMIT("# Generate statement, %u", node->type);
    // TODO: 2.4
    for (size_t i = 0; i < node->n_children; i++)
    {
        node_t *child = node->children[i];
        EMIT("# Checking child of %u, %u", node->type, child->type);
        switch (child->type)
        {
        case LIST:
        case BLOCK:
            generate_statement(child);
            break;
        case ASSIGNMENT_STATEMENT:
            generate_assignment_statement(child);
            break;
        case PRINT_STATEMENT:
            generate_print_statement(child);
            break;
        case RETURN_STATEMENT:
            generate_return_statement(child);
            break;
        case FUNCTION_CALL:
            generate_function_call(child);
            break;
        default:
            break;
        }
    }
    
}

static void generate_safe_printf ( void )
{
    LABEL ( "safe_printf" );

    PUSHQ ( RBP );
    MOVQ ( RSP, RBP );
    // This is a bitmask that abuses how negative numbers work, to clear the last 4 bits
    // A stack pointer that is not 16-byte aligned, will be moved down to a 16-byte boundary
    ANDQ ( "$-16", RSP );
    EMIT ( "call printf" );
    // Cleanup the stack back to how it was
    MOVQ ( RBP, RSP );
    POPQ ( RBP );
    RET;
}

static void generate_main ( symbol_t *first )
{
    // Make the globally available main function
    LABEL ( "main" );

    // Save old base pointer, and set new base pointer
    PUSHQ ( RBP );
    MOVQ ( RSP, RBP );

    // Which registers argc and argv are passed in
    const char* argc = RDI;
    const char* argv = RSI;

    const size_t expected_args = FUNC_PARAM_COUNT ( first );

    SUBQ ( "$1", argc ); // argc counts the name of the binary, so subtract that
    EMIT ( "cmpq $%ld, %s", expected_args, argc );
    JNE ( "ABORT" ); // If the provdied number of arguments is not equal, go to the abort label

    if (expected_args == 0)
        goto skip_args; // No need to parse argv

    // Now we emit a loop to parse all parameters, and push them to the stack,
    // in right-to-left order

    // First move the argv pointer to the vert rightmost parameter
    EMIT( "addq $%ld, %s", expected_args*8, argv );

    // We use rcx as a counter, starting at the number of arguments
    MOVQ ( argc, RCX );
    LABEL ( "PARSE_ARGV" ); // A loop to parse all parameters
    PUSHQ ( argv ); // push registers to caller save them
    PUSHQ ( RCX );

    // Now call strtol to parse the argument
    EMIT ( "movq (%s), %s", argv, RDI ); // 1st argument, the char *
    MOVQ ( "$0", RSI ); // 2nd argument, a null pointer
    MOVQ ( "$10", RDX ); //3rd argument, we want base 10
    EMIT ( "call strtol" );

    // Restore caller saved registers
    POPQ ( RCX );
    POPQ ( argv );
    PUSHQ ( RAX ); // Store the parsed argument on the stack

    SUBQ ( "$8", argv ); // Point to the previous char*
    EMIT ( "loop PARSE_ARGV" ); // Loop uses RCX as a counter automatically

    // Now, pop up to 6 arguments into registers instead of stack
    for ( size_t i = 0; i < expected_args && i < NUM_REGISTER_PARAMS; i++ )
        POPQ ( REGISTER_PARAMS[i] );

    skip_args:

    EMIT ( "call .%s", first->name );
    MOVQ ( RAX, RDI ); // Move the return value of the function into RDI
    EMIT ( "call exit" ); // Exit with the return value as exit code

    LABEL ( "ABORT" ); // In case of incorrect number of arguments
    EMIT ( "leaq errout(%s), %s", RIP, RDI );
    EMIT ( "call puts" ); // print the errout string
    MOVQ ( "$1", RDI );
    EMIT ( "call exit" ); // Exit with return code 1

    generate_safe_printf();

    // Declares global symbols we use or emit, such as main, printf and putchar
    DIRECTIVE ( "%s", ASM_DECLARE_SYMBOLS );
}
