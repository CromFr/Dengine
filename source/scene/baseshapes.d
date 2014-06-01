module scene.baseshapes;

public import scene.nodemodel;

import std.math;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import opengl.shader;
import opengl.program;
import resource;


class Tetrahedron : NodeModel {
	this(ref Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0)){
		super(parent, pos, rot);

		enum A = [0,0,sqrt(2.0/3.0)-1.0/(2.0*sqrt(6.0))];
		enum B = [-1.0/(2.0*sqrt(3.0)), -0.5, -1.0/(2.0*sqrt(6.0))];
		enum C = [-1.0/(2.0*sqrt(3.0)), 0.5, -1.0/(2.0*sqrt(6.0))];
		enum D = [1/sqrt(3.0), 0, -1/(2.0*sqrt(6.0))];

		m_vertices = A~B~C ~ D ~ A ~ B;

		enum r = [1,0,0];
		enum g = [0,1,0];
		enum b = [0,0,1];
		enum y = [1,1,0];

		m_colors = r~g~b~y~r~g;

		m_prog = Resource.Get!Program("default.prg").id;
	}

	override void Render(ref mat4 proj, ref mat4 mdlview){
		//writeln("Render");
		glUseProgram(m_prog);

			glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, m_vertices.ptr);
			glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, m_colors.ptr);
			glEnableVertexAttribArray(0);
			glEnableVertexAttribArray(1);

			glUniformMatrix4fv(glGetUniformLocation(m_prog, "projection"), 1, true, proj.value_ptr);
			glUniformMatrix4fv(glGetUniformLocation(m_prog, "modelview"), 1, true, mdlview.value_ptr);
			
			glDrawArrays(GL_TRIANGLE_STRIP, 0, to!int(m_vertices.length/3));

			glDisableVertexAttribArray(1);
			glDisableVertexAttribArray(0);

		glUseProgram(0);
	}

private:
	int m_prog;
}


class Cube : NodeModel {
	this(ref Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0)){
		super(parent, pos, rot);

		enum A = [0.5,	0.5,	0.5];
		enum B = [0.5,	-0.5,	0.5];
		enum C = [-0.5,	-0.5,	0.5];
		enum D = [-0.5,	0.5,	0.5];

		enum E = [0.5,	0.5,	-0.5];
		enum F = [0.5,	-0.5,	-0.5];
		enum G = [-0.5,	-0.5,	-0.5];
		enum H = [-0.5,	0.5,	-0.5];

		m_vertices = 
			 A~B~C~A~C~D
			~B~F~G~B~G~C
			~A~E~F~A~F~B
			~E~H~G~E~G~F
			~D~C~G~D~G~H
			~E~A~D~E~D~H;

		enum r = [1,0,0];
		enum g = [0,1,0];
		enum b = [0,0,1];
		enum y = [1,1,0];
		enum c = [0,1,1];
		enum m = [1,0,1];

		m_colors =
			 r~r~r~r~r~r
			~g~g~g~g~g~g
			~b~b~b~b~b~b
			~y~y~y~y~y~y
			~c~c~c~c~c~c
			~m~m~m~m~m~m;

		m_prog = Resource.Get!Program("default.prg").id;
	}

	override void Render(ref mat4 proj, ref mat4 mdlview){
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

private:
	int m_prog;
}