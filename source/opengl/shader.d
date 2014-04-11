module opengl.shader;

import std.file;
import std.conv : to;
import derelict.opengl3.gl3;


enum ShaderType{
	Fragment = GL_FRAGMENT_SHADER,
	Vertex = GL_VERTEX_SHADER
}

class Shader{
	this(DirEntry file, ShaderType type){
		immutable char sourcecode[] = file.readText();
		this(sourcecode.ptr, type);
	}
	this(immutable(char)* sourcecode, ShaderType type){
		m_id = glCreateShader(type);
		if(m_id==0)
			throw new Exception("'"~type.stringof~"' is not a shader type");

		//Compile
		//void glShaderSource(GLuint shader, GLsizei count, const GLchar **string, const GLint *length)
		glShaderSource(m_id, 1, &sourcecode, null);
		glCompileShader(m_id);

		//Check
		int success;
		glGetShaderiv(m_id, GL_COMPILE_STATUS, &success);
		if(!success){
			int length;
			glGetShaderiv(m_id, GL_INFO_LOG_LENGTH, &length);

			char info[];
			info.length = length;

			//glGetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
			glGetShaderInfoLog(m_id, length, &length, info.ptr);
			throw new Exception("Shader compilation error: "~to!string(info));
		}
		m_compiled = true;
	}

	~this(){
		if(m_id!=0)
			glDeleteShader(m_id);
	}



	@property{
		uint id()const{return m_id;}
		ShaderType type()const{return m_type;}
		bool compiled()const{return m_compiled;}
	}



private:
	uint m_id;
	ShaderType m_type;
	bool m_compiled = false;
}

