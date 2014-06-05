module base.vect3d;

alias Vect3Df = Vect3D!float;
alias Vect3Di = Vect3D!uint;

struct Vect3D(T) {
	this(T _x, T _y, T _z){
		m_x=_x; m_y=_y; m_z=_z;
	}

	@property{
		T x()const{return m_x;}
		void x(T _x){m_x=_x;}
		T y()const{return m_y;}
		void y(T _y){m_y=_y;}
		T z()const{return m_z;}
		void z(T _z){m_z=_z;}
	}

	bool opEquals(const Vect3D!T other)const{
	  return (m_x==other.m_x && m_y==other.m_y && m_z==other.m_z);
	}

	Vect3D!T opBinary(string op)(const Vect3D!T other)const{
		return Vect3D!T(mixin("m_x "~op~" other.m_x"), mixin("m_y "~op~" other.m_y"), mixin("m_z "~op~" other.m_z"));
	}
	Vect3D!T opBinary(string op, O)(const O other)const
		if(__traits(isArithmetic, O)){
		return Vect3D!T(mixin("m_x "~op~" other"), mixin("m_y "~op~" other"), mixin("m_z "~op~" other"));
	}

	T[] opSlice(){
		return [m_x, m_y, m_z];
	}

	void opOpAssign(string op)(const Vect3D!T other){
		mixin("this.m_x "~op~"= other.m_x;");
		mixin("this.m_y "~op~"= other.m_y;");
		mixin("this.m_z "~op~"= other.m_z;");
	}

	static T[] toVertexList(const ref Vect3D!T[] array){
		T[] tmp;
		foreach(vect ; array){
			tmp~=[vect.m_x, vect.m_y, vect.m_z];
		}
		return tmp;
	}




private:
	T m_x=0, m_y=0, m_z=0;
}