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
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df sca=Vect3Df(1,1,1)){
		super(parent, pos, rot, sca);
		
		Vbo vbo;
		//Load data in VBO, create it if not exist
		try vbo = Resource.Get!Vbo("_Tetrahedron");
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

			vbo = Resource.CreateRes!Vbo("_Tetrahedron", Vbo.Rate.Rarely, vertices, colors);
		}

		auto rt = new RenderTask(
			Resource.Get!Program("default.prg"),
			RenderTask.DrawMode.TriangleStrip, 6
		);

		rt.AssignVertex(vbo, 
				VertexAddress(0, 3, 0),
				VertexAddress(1, 3, 1),
		);

		rt.Prepare("_Tetrahedron");

		m_renderTasks ~= rt;
	}

	
}


class Cube : NodeModel {
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df sca=Vect3Df(1,1,1)){
		super(parent, pos, rot, sca);

		Vbo vbo;
		try vbo = Resource.Get!Vbo("_Cube");
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

			vbo = Resource.CreateRes!Vbo("_Cube", Vbo.Rate.Rarely, vertices, colors);
		}

		auto rt = new RenderTask(
			Resource.Get!Program("default.prg"),
			RenderTask.DrawMode.Triangle, 36
		);

		rt.AssignVertex(vbo, 
				VertexAddress(0, 3, 0),
				VertexAddress(1, 3, 1),
		);

		rt.Prepare("_Cube");

		m_renderTasks ~= rt;
	}
}


class Crate : Cube {
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df sca=Vect3Df(1,1,1)){
		super(parent, pos, rot, sca);

		Vbo vbo;
		try vbo = Resource.Get!Vbo("_Crate");
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

			vbo = Resource.CreateRes!Vbo("_Crate", Vbo.Rate.Rarely, texturecoord);
		}

		m_renderTasks[0].program = Resource.Get!Program("texture.prg");

		m_renderTasks[0].AssignVertex(vbo, 
				VertexAddress(0, 2, 2)
		);
		auto text = Resource.Get!Texture("crate.jpg");

		m_renderTasks[0].AssignTexture(text);

		m_renderTasks[0].Prepare("_Crate");
	}
}


class Axis : NodeModel {
	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df sca=Vect3Df(1,1,1)){
		super(parent, pos, rot, sca);

		Vbo vbo;
		try vbo = Resource.Get!Vbo("_Axis");
		catch(ResourceException e){

			float vertices[]= [	0,0,0, 1,0,0,
								0,0,0, 0,1,0,
								0,0,0, 0,0,1];

			float verticesarrow[]= [
				1,0,0, 0.9,0.05,0, 0.9,-0.05,0,
				1,0,0, 0.9,0,0.05, 0.9,0,-0.05,

				0,1,0, 0.05,0.9,0, -0.05,0.9,0,
				0,1,0, 0,0.9,0.05, 0,0.9,-0.05,

				0,0,1, 0.05,0,0.9, -0.05,0,0.9,
				0,0,1, 0,0.05,0.9, 0,-0.05,0.9,
				];

			enum r = [1,0,0];
			enum g = [0,1,0];
			enum b = [0,0,1];

			float colors[] = r~r~g~g~b~b;
			float colorsarrow[] =	r~r~r~ r~r~r~ 
									g~g~g~ g~g~g~ 
									b~b~b~ b~b~b ;

			vbo = Resource.CreateRes!Vbo("_Axis", Vbo.Rate.Rarely, vertices, colors, verticesarrow, colorsarrow);
		}

		//Lines
		auto rt = new RenderTask(
			Resource.Get!Program("default.prg"),
			RenderTask.DrawMode.Line, 6
		);

		rt.AssignVertex(vbo, 
				VertexAddress(0, 3, 0),
				VertexAddress(1, 3, 1),
		);

		rt.Prepare("_AxisLines");
		m_renderTasks ~= rt;

		//
		auto rt2 = new RenderTask(
			Resource.Get!Program("default.prg"),
			RenderTask.DrawMode.Triangle, 18
		);

		rt2.AssignVertex(vbo, 
				VertexAddress(2, 3, 0),
				VertexAddress(3, 3, 1),
		);

		rt2.Prepare("_AxisArrows");
		m_renderTasks ~= rt2;
	}
}