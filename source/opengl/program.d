module opengl.program;

import std.string;
import std.conv : to;
import std.file : DirEntry, readText;
import std.json;
import derelict.opengl3.gl3;

import opengl.shader;
import resource;

class ProgramException : Exception{
	enum Type{
		Linkage,
		Creation
	}

	this(in string _msg, in Type _type, in string _filepath){
		type = _type;
		filepath = _filepath;

		super("OpenGL Program "~to!string(type)~" exception@"~filepath~" "~_msg);
	}

	immutable Type type;
	immutable string filepath;
}

class Program {
	this(in uint[] shaders, in char[] attribLoc...) {
		m_filepath = "";

		m_id = glCreateProgram();
		if(m_id==0)
			throw new ProgramException("Created invalid ID", ProgramException.Type.Creation, m_filepath);

		foreach(shaderid ; shaders){
			glAttachShader(m_id, shaderid);
		}

	    //Bind attributes
	    foreach(index, s ; attribLoc){
			glBindAttribLocation(m_id, to!uint(index), &s);
	    }
	    Link();
	}

	this(DirEntry file){
		m_filepath = file.name;

		m_id = glCreateProgram();
		if(m_id==0)
			throw new ProgramException("Created invalid ID", ProgramException.Type.Creation, m_filepath);

		JSONValue jsonFile = parseJSON(file.readText().removechars("\n\r\t"));

		foreach(ref shader ; jsonFile["shaders"].array){
		    glAttachShader(m_id, Resource.Get!Shader(shader.str).id);
		}

		foreach(index, ref shader ; jsonFile["binds"].object){
		    glBindAttribLocation(m_id, to!uint(index), shader.str.ptr);
		}

		Link();
	}

	@property{
		uint id()const{return m_id;}
		bool linked()const{return m_linked;}
	}

	void Bind()const{
		glUseProgram(m_id);
	}
	static void Unbind(){
		glUseProgram(0);
	}


private:
	immutable uint m_id;
	bool m_linked = false;
	immutable string m_filepath;

	void Link(){
		//Link
		glLinkProgram(m_id);

		//Check
		int success;
		glGetProgramiv(m_id, GL_LINK_STATUS, &success);
		if(!success){
			int length;
			glGetProgramiv(m_id, GL_INFO_LOG_LENGTH, &length);

			char[] info;
			info.length = length;

			//glGetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
			glGetProgramInfoLog(m_id, length, &length, info.ptr);
			throw new ProgramException(to!string(info), ProgramException.Type.Linkage, m_filepath);
		}
		m_linked = true;
	}
}