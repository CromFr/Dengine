module opengl.vao;

import std.conv : to;
import derelict.opengl3.gl3;

class VaoException : Exception{
	enum Type{ Creation }

	this(in string _msg, in Type _type){
		type = _type;
		super("OpenGL VAO "~to!string(type)~" exception: "~_msg);
	}

	immutable Type type;
}

/**
	Vertex Array Object
	Preloads some functions to be executed on the GPU while rendering
	Notes: Needs to be binded to render something
**/
class Vao{

	this(void delegate() f){
		glGenVertexArrays(1, &m_id);
		if(m_id==0)
			throw new VaoException("Created invalid ID", VaoException.Type.Creation);

		glBindVertexArray(m_id);

		f();

		glBindVertexArray(0);
	}
	~this(){
		glDeleteVertexArrays(1, &m_id);
	}

	void Bind()const{
		glBindVertexArray(m_id);
	}
	static void Unbind(){
		glBindVertexArray(0);
	}


private:
	uint m_id;
}