module opengl.vbo;

import std.conv : to;
import derelict.opengl3.gl3;

class VboException : Exception{
	enum Type{ Creation,NoSpace }

	this(in string _msg, in Type _type){
		type = _type;
		super("OpenGL VBO "~to!string(type)~" exception: "~_msg);
	}

	immutable Type type;
}

/**
	Vertex Buffer Object
	Handles data stored in the GPU VRAM
**/
class Vbo{
	enum Rate{
		Rarely = GL_STATIC_DRAW,
		Often = GL_DYNAMIC_DRAW,
		Always = GL_STREAM_DRAW
	}
	this(VT...)(in Rate update, in VT data){
		m_update = update;

		void[] dataarray;
		uint index = 0;
		foreach(d ; data){
			m_dataindex ~= index;
			dataarray ~= cast(void[])(d);
			uint length = to!uint(d.length * d[0].sizeof);
			index += length;
			m_datalength ~= length;
		}
		m_totallength = to!uint(dataarray.length);

		//prepare
		glGenBuffers(1, &m_id);
		if(m_id==0)
			throw new VboException("Created invalid ID", VboException.Type.Creation);

		Bind();

		//Load data
		//glBufferData(GLenum target, GLsizeiptr size, const GLvoid *data, GLenum  usage)
		glBufferData(GL_ARRAY_BUFFER, m_totallength, dataarray.ptr, update);

		Unbind();
	}
	~this(){
		glDeleteBuffers(1, &m_id);
	}

	void Bind(){
		glBindBuffer(GL_ARRAY_BUFFER, m_id);
	}
	static void Unbind(){
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}


	void opIndexAssign(T)(T[] data, size_t i){
		assert(i<m_dataindex.length, "Index out of bound");

		if(    (i+1<m_dataindex.length && m_dataindex[i]+data.sizeof<=m_dataindex[i+1])
			|| (m_dataindex[i]+data.sizeof<=m_totallength)
			){
			glBufferSubData(GL_ARRAY_BUFFER, m_dataindex[i], m_datalength[i], data.ptr);
			}
		else
			throw new VboException("No space to load data in the cell", VboException.Type.NoSpace);
	}

	@property{
		uint id()const{return m_id;}

		uint[] length()const{
			return m_datalength.dup;
		}
		uint[] offset()const{
			return m_dataindex.dup;
		}
	}

private:
	uint m_id;
	Rate m_update;

	uint m_totallength;
	uint m_dataindex[];
	uint m_datalength[];

}