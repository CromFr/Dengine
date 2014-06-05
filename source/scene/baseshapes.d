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
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df scale=Vect3Df(0,0,0)){
		super(6, parent, pos, rot, scale);
		drawMode = DrawMode.TriangleStrip;
		
		//Load data in VBO, create it if not exist
		try m_vbo ~= Resource.Get!Vbo("TetrahedronData");
		catch(ResourceException e){

			enum A = [0,0,sqrt(2.0/3.0)-1.0/(2.0*sqrt(6.0))];
			enum B = [-1.0/(2.0*sqrt(3.0)), -0.5, -1.0/(2.0*sqrt(6.0))];
			enum C = [-1.0/(2.0*sqrt(3.0)), 0.5, -1.0/(2.0*sqrt(6.0))];
			enum D = [1/sqrt(3.0), 0, -1/(2.0*sqrt(6.0))];

			float vertices[] = A~B~C ~ D ~ A ~ B;

			enum r = [1,0,0];
			enum g = [0,1,0];
			enum b = [0,0,1];
			enum y = [1,1,0];

			float colors[] = r~g~b~y~r~g;

			m_vbo ~= Resource.CreateRes!Vbo("TetrahedronData", Vbo.Rate.Rarely, vertices, colors);
		}

		//Create VAO if not exists
		try m_vao = Resource.Get!Vao("Tetrahedron");
		catch(ResourceException e){
			m_vao = Resource.CreateRes!Vao("Tetrahedron", {
				//These lines will be executed on graphic card for each render
				m_vbo[0].Bind();
				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[0]));
				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[1]));
				glEnableVertexAttribArray(0);
				glEnableVertexAttribArray(1);
				Vbo.Unbind();
			});
		}

		m_prog = Resource.Get!Program("default.prg");
	}

	
}


class Cube : NodeModel {
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df scale=Vect3Df(0,0,0)){
		super(36, parent, pos, rot, scale);

		try m_vbo ~= Resource.Get!Vbo("CubeData");
		catch(ResourceException e){
			enum A = [0.5,	0.5,	0.5];
			enum B = [0.5,	-0.5,	0.5];
			enum C = [-0.5,	-0.5,	0.5];
			enum D = [-0.5,	0.5,	0.5];

			enum E = [0.5,	0.5,	-0.5];
			enum F = [0.5,	-0.5,	-0.5];
			enum G = [-0.5,	-0.5,	-0.5];
			enum H = [-0.5,	0.5,	-0.5];

			float vertices[] = 
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

			float colors[] =
				 r~r~r~r~r~r
				~g~g~g~g~g~g
				~b~b~b~b~b~b
				~y~y~y~y~y~y
				~c~c~c~c~c~c
				~m~m~m~m~m~m;

			m_vbo ~= Resource.CreateRes!Vbo("CubeData", Vbo.Rate.Rarely, vertices, colors);
		}

		try m_vao = Resource.Get!Vao("Cube");
		catch(ResourceException e){
			m_vao = Resource.CreateRes!Vao("Cube", {
				m_vbo[0].Bind();
				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[0]));
				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[1]));
				glEnableVertexAttribArray(0);
				glEnableVertexAttribArray(1);
				Vbo.Unbind();
			});
		}

		m_prog = Resource.Get!Program("default.prg");
	}
}


class Crate : Cube {

	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df scale=Vect3Df(0,0,0)){
		super(parent, pos, rot, scale);
		m_prog = Resource.Get!Program("texture.prg");

		Texture texture = Resource.Get!Texture("crate.jpg");

		try m_vbo ~= Resource.Get!Vbo("CrateText");
		catch(ResourceException e){

			enum bl = [0.0,0.0];
			enum br = [1.0,0.0];
			enum tl = [0.0,1.0];
			enum tr = [1.0,1.0];

			float texturecoord[] = 
				 tr~br~bl~tr~bl~tl
				~br~tr~tl~br~tl~bl
				~tl~tr~br~tl~br~bl
				~tl~tr~br~tl~br~bl
				~tr~br~bl~tr~bl~tl
				~tr~br~bl~tr~bl~tl;

			m_vbo ~= Resource.CreateRes!Vbo("CrateText", Vbo.Rate.Rarely, texturecoord);
		}

		try m_vao = Resource.Get!Vao("Crate");
		catch(ResourceException e){
			m_vao = Resource.CreateRes!Vao("Crate", {
				m_vbo[0].Bind();
				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[0]));
				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[1]));
				glEnableVertexAttribArray(0);
				glEnableVertexAttribArray(1);
				m_vbo[1].Bind();
				glVertexAttribPointer(2, 2, GL_FLOAT, false, 0, cast(void*)(m_vbo[1].offset[0]));
				glEnableVertexAttribArray(2);
				Vbo.Unbind();

				texture.Bind();
			});
		}
	}
}


class Axis : NodeModel {
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df scale=Vect3Df(0,0,0)){
		super(6, parent, pos, rot, scale);

		drawMode = DrawMode.Line;
		m_prog = Resource.Get!Program("default.prg");

		try m_vbo ~= Resource.Get!Vbo("AxisData");
		catch(ResourceException e){

			float vertices[]= [	0,0,0, 1,0,0,
								0,0,0, 0,1,0,
								0,0,0, 0,0,1];

			enum r = [1,0,0];
			enum g = [0,1,0];
			enum b = [0,0,1];

			float colors[] = r~r~g~g~b~b;

			m_vbo ~= Resource.CreateRes!Vbo("AxisData", Vbo.Rate.Rarely, vertices, colors);
		}

		try m_vao = Resource.Get!Vao("Axis");
		catch(ResourceException e){
			m_vao = Resource.CreateRes!Vao("Axis", {
				m_vbo[0].Bind();
				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[0]));
				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[1]));
				glEnableVertexAttribArray(0);
				glEnableVertexAttribArray(1);
				Vbo.Unbind();
			});
		}
	}
}