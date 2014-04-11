module unit;

public import std.stdio;
public import core.exception;

void PrintStart(string mod=__MODULE__){
	writeln("starting "~mod~" unittest...");
}
void PrintEnd(string mod=__MODULE__){
	writeln("======>> \x1b[32m"~mod~" unittest \x1b[7mDONE\x1b[m");
}