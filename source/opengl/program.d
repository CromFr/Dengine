module opengl.program;

import std.string;
import std.conv : to;
import std.file : DirEntry, readText;
import std.json;
import derelict.opengl3.gl3;

import opengl.shader;
import resource;

class Program {
	this(in uint shaders[], in char[] attribLoc...) {
		m_id = glCreateProgram();
		if(m_id==0)
			throw new Exception("Invalid program id");

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
		m_id = glCreateProgram();
		if(m_id==0)
			throw new Exception("Invalid program id");

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


private:
	uint m_id;
	bool m_linked = false;

	void Link(){
		//Link
		glLinkProgram(m_id);

		//Check
		int success;
		glGetProgramiv(m_id, GL_LINK_STATUS, &success);
		if(!success){
			int length;
			glGetProgramiv(m_id, GL_INFO_LOG_LENGTH, &length);

			char info[];
			info.length = length;

			//glGetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
			glGetProgramInfoLog(m_id, length, &length, info.ptr);
			throw new Exception("Program linkage error: "~to!string(info));
		}
		m_linked = true;
	}
}