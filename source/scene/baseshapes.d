module scene.baseshapes;

public import scene.nodemodel;

import std.math;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import opengl.shader;
import opengl.program;
import opengl.texture;
import opengl.vbo;
import opengl.vao;
import resource;


class Tetrahedron : NodeModel {
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0)){
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
		
		//Load data in VBO, create it if not exist
		try m_vbo = Resource.Get!Vbo("TetrahedronData");
		catch(ResourceException e){
			m_vbo = Resource.CreateRes!Vbo("TetrahedronData", Vbo.Rate.Rarely, m_vertices, m_colors);
		}

		//These lines will be executed on graphic card for each render
		m_vao = new Vao({
				m_vbo.Bind();
				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo.offset[0]));
				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo.offset[1]));
				glEnableVertexAttribArray(0);
				glEnableVertexAttribArray(1);
				Vbo.Unbind();
			});

		m_prog = Resource.Get!Program("default.prg").id;
	}

	override void Render(ref mat4 proj, ref mat4 mdlview){
		glUseProgram(m_prog);
		m_vao.Bind();

			//Send matrix
			glUniformMatrix4fv(glGetUniformLocation(m_prog, "projection"), 1, true, proj.value_ptr);
			glUniformMatrix4fv(glGetUniformLocation(m_prog, "modelview"), 1, true, mdlview.value_ptr);
			
			//Render !
			std.stdio.writeln(m_vbo.length[0]);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, m_vbo.length[0]/12);

		Vao.Unbind();
		glUseProgram(0);
	}

protected:
	int m_prog;
	Vbo m_vbo;
	Vao m_vao;
}


class Cube : NodeModel {
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0)){
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

		try m_vbo = Resource.Get!Vbo("CubeData");
		catch(ResourceException e){
			m_vbo = Resource.CreateRes!Vbo("CubeData", Vbo.Rate.Rarely, m_vertices, m_colors);
		}

		m_vao = new Vao({
				m_vbo.Bind();
				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo.offset[0]));
				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo.offset[1]));
				glEnableVertexAttribArray(0);
				glEnableVertexAttribArray(1);
				Vbo.Unbind();
			});
	}

	override void Render(ref mat4 proj, ref mat4 mdlview){
		glUseProgram(m_prog);
		m_vao.Bind();

			glUniformMatrix4fv(glGetUniformLocation(m_prog, "projection"), 1, true, proj.value_ptr);
			glUniformMatrix4fv(glGetUniformLocation(m_prog, "modelview"), 1, true, mdlview.value_ptr);
			
			glDrawArrays(GL_TRIANGLES, 0, m_vbo.length[0]/12);

		Vao.Unbind();
		glUseProgram(0);
	}

protected:
	int m_prog;
	Vbo m_vbo;
	Vao m_vao;
}


class Crate : Cube {

	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0)){
		super(parent, pos, rot);

		enum bl = [0.0,0.0];
		enum br = [1.0,0.0];
		enum tl = [0.0,1.0];
		enum tr = [1.0,1.0];

		m_texturecoord = 
			 tr~br~bl~tr~bl~tl
			~br~tr~tl~br~tl~bl
			~tl~tr~br~tl~br~bl
			~tl~tr~br~tl~br~bl
			~tr~br~bl~tr~bl~tl
			~tr~br~bl~tr~bl~tl;

		m_texture = Resource.Get!Texture("crate.jpg");
		m_prog = Resource.Get!Program("texture.prg").id;

		try m_vbotext = Resource.Get!Vbo("CrateText");
		catch(ResourceException e){
			m_vbotext = Resource.CreateRes!Vbo("CrateText", Vbo.Rate.Rarely, m_texturecoord);
		}

		m_vao = new Vao({
				m_vbo.Bind();
				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo.offset[0]));
				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo.offset[1]));
				glEnableVertexAttribArray(0);
				glEnableVertexAttribArray(1);
				m_vbotext.Bind();
				glVertexAttribPointer(2, 2, GL_FLOAT, false, 0, cast(void*)(m_vbotext.offset[0]));
				glEnableVertexAttribArray(2);
				Vbo.Unbind();

				m_texture.Bind();
			});
	}

	override void Render(ref mat4 proj, ref mat4 mdlview){
		glUseProgram(m_prog);
			m_vao.Bind();

			glUniformMatrix4fv(glGetUniformLocation(m_prog, "projection"), 1, true, proj.value_ptr);
			glUniformMatrix4fv(glGetUniformLocation(m_prog, "modelview"), 1, true, mdlview.value_ptr);

			glDrawArrays(GL_TRIANGLES, 0, m_vbo.length[0]/12);
			
			Vao.Unbind();
		glUseProgram(0);
	}

	Texture m_texture;
	float m_texturecoord[];
	Vbo m_vbotext;
}


class Axis : NodeModel {
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0)){
		super(parent, pos, rot);

		

		m_vertices = [	0,0,0, 1,0,0,
						0,0,0, 0,1,0,
						0,0,0, 0,0,1];

		enum r = [1,0,0];
		enum g = [0,1,0];
		enum b = [0,0,1];

		m_colors = r~r~g~g~b~b;

		m_prog = Resource.Get!Program("default.prg").id;

		try m_vbo = Resource.Get!Vbo("AxisData");
		catch(ResourceException e){
			m_vbo = Resource.CreateRes!Vbo("AxisData", Vbo.Rate.Rarely, m_vertices, m_colors);
		}

		m_vao = new Vao({
				m_vbo.Bind();
				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo.offset[0]));
				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo.offset[1]));
				glEnableVertexAttribArray(0);
				glEnableVertexAttribArray(1);
				Vbo.Unbind();
			});
	}

	override void Render(ref mat4 proj, ref mat4 mdlview){
		glUseProgram(m_prog);
		m_vao.Bind();

			glUniformMatrix4fv(glGetUniformLocation(m_prog, "projection"), 1, true, proj.value_ptr);
			glUniformMatrix4fv(glGetUniformLocation(m_prog, "modelview"), 1, true, mdlview.value_ptr);
			
			glDrawArrays(GL_LINES, 0, m_vbo.length[0]/12);

		Vao.Unbind();
		glUseProgram(0);
	}

protected:
	int m_prog;
	Vbo m_vbo;
	Vao m_vao;
}