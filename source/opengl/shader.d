module opengl.shader;

import std.file;
import std.conv : to;
import derelict.opengl3.gl3;

class ShaderException : Exception{
	enum Type{
		Compilation,
		Creation
	}

	this(in string _msg, in Type _type, in string _filepath){
		type = _type;
		filepath = _filepath;

		super("OpenGL Shader "~to!string(type)~" exception@"~filepath~" "~_msg);
	}

	immutable Type type;
	immutable string filepath;
}


enum ShaderType{
	Fragment = GL_FRAGMENT_SHADER,
	Vertex = GL_VERTEX_SHADER
}

class Shader{
	this(DirEntry file, ShaderType type){
		immutable char[] sourcecode = file.readText();
		this(sourcecode.ptr, type, file.name);
	}
	this(immutable(char)* sourcecode, ShaderType type, in string filepath=""){
		m_filepath = filepath;
		m_type = type;

		m_id = glCreateShader(m_type);
		if(m_id==0)
			throw new ShaderException("'"~to!string(m_type)~"' is not a shader type", ShaderException.Type.Creation, m_filepath);

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

			char[] info;
			info.length = length;

			//glGetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
			glGetShaderInfoLog(m_id, length, &length, info.ptr);
			throw new ShaderException(to!string(info), ShaderException.Type.Compilation, m_filepath);

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
	immutable uint m_id;
	immutable ShaderType m_type;
	bool m_compiled = false;
	immutable string m_filepath;
}

