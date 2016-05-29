module base.color;

import std.traits;
import std.algorithm;

struct Color{



	this(in ubyte r, in ubyte g, in ubyte b, in ubyte a=ubyte.max){
		m_valuergba = [r, g, b, a];
	}

	ubyte[] opSlice(){
		return m_valuergba[];
	}

	static Color From(string F, VT...)(in VT args)
		if(F=="rgb"||F=="rgba"||F=="hsva")
	{
		//=====================================================
		static if(F=="rgb" && args.length==3){
			static if(__traits(isFloating, args[])){
				return From!"rgba"(args, 1.0);
			}
			else static if(__traits(isIntegral, args[])){
				return From!"rgba"(args, 255);
			}
			else
				static assert(0,"Color argument type error");
		}
		else static if(F=="rgba" && args.length==4){

			static if(__traits(isFloating, args[])){
				return Color(
					cast(ubyte)(args[0]*255),
					cast(ubyte)(args[1]*255),
					cast(ubyte)(args[2]*255),
					cast(ubyte)(args[3]*255));
			}
			else static if(__traits(isIntegral, args[])){
				return Color(
					cast(ubyte)(args[]));
			}
			else
				static assert(0,"Color argument type error");
		}
		//=====================================================
		else static if(F=="hsva" && args.length==4){
			//TODO
			static assert(0, "Not working correctly");

			if(args[1]==0)
				return Color(ubyte.max,ubyte.max,ubyte.max);

			float H, S, V;
			static if(__traits(isIntegral, args[])){
				H = args[0]*360.0/255.0;
				S = args[1]/255.0;
				V = args[2]/255.0;
			}
			else{
				H = args[0]*360.0;
				S = args[1];
				V = args[2];
			}

			if(S==0)
				return Color(cast(ubyte)(V*255), cast(ubyte)(V*255), cast(ubyte)(V*255)	);

			H /= 60.0;
			ubyte i = cast(ubyte)(H);
			float f = H-i;
			float[3] val = [
				V*(1.0-S),
				V*(1-S*f),
				V*(1-S*(1-f))
			];

			std.stdio.writeln(i);
			switch(i){
				case 0: return Color(cast(ubyte)(V*255), 		cast(ubyte)(val[2]*255),	cast(ubyte)(val[0]*255)	);
				case 1: return Color(cast(ubyte)(val[1]*255), 	cast(ubyte)(V*255), 		cast(ubyte)(val[0]*255)	);
				case 2: return Color(cast(ubyte)(val[0]*255), 	cast(ubyte)(V*255), 		cast(ubyte)(val[2]*255)	);
				case 3: return Color(cast(ubyte)(val[0]*255), 	cast(ubyte)(val[1]*255), 	cast(ubyte)(V*255)		);
				case 4: return Color(cast(ubyte)(val[2]*255), 	cast(ubyte)(val[0]*255), 	cast(ubyte)(V*255)		);
				case 5: return Color(cast(ubyte)(V*255), 		cast(ubyte)(val[0]*255), 	cast(ubyte)(val[1]*255)	);
				default:assert(0,"Color conversion error (HSV to RVB)");
			}
		}
		//=====================================================
		else
			static assert(0,"Color argument error");
	}



private:
	ubyte[4] m_valuergba;

}


unittest{
	auto c = Color(165,45,21);

	assert(c[] == (Color.From!"rgb"(165,45,21))[]);
	assert(c[] == (Color.From!"rgb"(0.647058825,0.176470589,0.082352942))[]);

	//assert(c[] == (Color.From!"hsv"(10, 87, 65))[]);


}
