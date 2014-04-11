module scene.testcube;
public import scene.nodemodel;

import std.stdio;
import std.conv;
import std.file;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

import opengl.shader;
import opengl.program;
import resource;


class TestCube : NodeModel {
	this(ref Node parent, const Vect3Df pos=Vect3Df(0,0,0), const Vect3Df rot=Vect3Df(0,0,0)){
		super(parent, pos, rot);

		enum v = 0.3;
		//m_vertices = [
		//	1,-1,-1, 1,1,-1, -1,1,-1, -1,-1,-1,
		//	1,-1,1, 1,1,1, 1,1,-1, 1,-1,-1,
		//	-1,-1,1, -1,1,1, 1,1,1, 1,-1,1,
		//	-1,-1,-1, -1,1,-1, -1,1,1, -1,-1,1, 
		//	1,-1,1, 1,-1,-1, -1,-1,-1, -1,-1,1,
		//	1,1,-1, 1,1,1, -1,1,1, -1,1,-1
		//	];

		m_vertices = [
			0,0,0,		0,-1,0,		0,-1,-1,
			0,0,0,		0,-1,0,		-1,-1,0,
			0,0,0,		0,-1,-1,	-1,-1,0,
			0,-1,0,		0,-1,-1,	-1,-1,0
			//-0.5,-0.5,0,	0.5,-0.5,0,		0,-0.5,0,		
			//0,0,-1.0,		-0.5,-0.5,0,	0,-0.5,0,
			//0.5,-0.5,0,		0,0,-1.0,		0,-0.5,0,
			//0,0,-1.0,		0.5,-0.5,0,		-0.5,-0.5,0,
		];

		//m_vertices = [0.0,0.0,-1.0,  0.5,0.0,-1.0,  0.0,0.5,-1.0];
		m_colors = [
			1,0,0, 0,1,0, 0,0,1,
			1,1,0, 0,1,1, 1,0,1,
			1,0,0, 0,1,0, 0,0,1,
			1,1,0, 0,1,1, 1,0,1,
		];

		

		m_prog = Resource.Get!Program("default.prg").id;
	}

	int m_prog;
	override void Render(ref mat4 proj, ref mat4 mdlview){
		//writeln("Render");
		glUseProgram(m_prog);

			glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, m_vertices.ptr);
			glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, m_colors.ptr);
			glEnableVertexAttribArray(0);
			glEnableVertexAttribArray(1);

			glUniformMatrix4fv(glGetUniformLocation(m_prog, "projection"), 1, true, proj.value_ptr);
			glUniformMatrix4fv(glGetUniformLocation(m_prog, "modelview"), 1, true, mdlview.value_ptr);
			
			glDrawArrays(GL_TRIANGLES, 0, to!int(m_vertices.length/3));

			glDisableVertexAttribArray(1);
			glDisableVertexAttribArray(0);

		glUseProgram(0);
	}


}