module base.color;

import std.traits;

struct Color{

	

	this(in ubyte r, in ubyte g, in ubyte b, in ubyte a=ubyte.max){
		m_valuergba = [r, g, b, a];
	}

	static Color From(string F, VT...)(in VT args){
		static if(
			F=="rgb"
			&& args.length==3
			&& __traits(isIntegral, args[])
			){
			return Color(cast(ubyte)(args[0..3]), ubyte.max);
		}
		else static if(
			F=="rgba" 
			&& args.length==4 
			&& __traits(isIntegral, args[])
			){
			return Color(cast(ubyte)(args[]));
		}
		else static if(
			F=="bgr" 
			&& args.length==3 
			&& __traits(isIntegral, args[])
			){
			return Color(cast(ubyte)(args[2]),cast(ubyte)(args[1]),cast(ubyte)(args[0]), ubyte.max);
		}
		else
			static assert("Unhandled color format");

		static assert("Color argument error");
	}



private:
	ubyte m_valuergba[4];

}

