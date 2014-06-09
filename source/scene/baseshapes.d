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
		try vbo = Resource.Get!Vbo(typeof(this).stringof);
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

			vbo = Resource.CreateRes!Vbo(typeof(this).stringof, Vbo.Rate.Rarely, vertices, colors);
		}

		auto rt = new RenderTask(
			Resource.Get!Program("default.prg"),
			RenderTask.DrawMode.TriangleStrip, 6
		);

		rt.AssignVertex(vbo, 
				VertexAddress(0, 3, 0),
				VertexAddress(1, 2, 1),
		);

		rt.Prepare(typeof(this).stringof);

		m_renderTasks ~= rt;
	}

	
}


class Cube : NodeModel {
	mixin NodeCtor;
	//this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df sca=Vect3Df(1,1,1)){
	//	super(parent, pos, rot, sca);

	//	Vbo vbo;
	//	try vbo = Resource.Get!Vbo("CubeData");
	//	catch(ResourceException e){
	//		enum A = [0.5,	0.5,	0.5];
	//		enum B = [0.5,	-0.5,	0.5];
	//		enum C = [-0.5,	-0.5,	0.5];
	//		enum D = [-0.5,	0.5,	0.5];

	//		enum E = [0.5,	0.5,	-0.5];
	//		enum F = [0.5,	-0.5,	-0.5];
	//		enum G = [-0.5,	-0.5,	-0.5];
	//		enum H = [-0.5,	0.5,	-0.5];

	//		float vertices[] = 
	//			 A~B~C~A~C~D
	//			~B~F~G~B~G~C
	//			~A~E~F~A~F~B
	//			~E~H~G~E~G~F
	//			~D~C~G~D~G~H
	//			~E~A~D~E~D~H;

	//		enum r = [1,0,0];
	//		enum g = [0,1,0];
	//		enum b = [0,0,1];
	//		enum y = [1,1,0];
	//		enum c = [0,1,1];
	//		enum m = [1,0,1];

	//		float colors[] =
	//			 r~r~r~r~r~r
	//			~g~g~g~g~g~g
	//			~b~b~b~b~b~b
	//			~y~y~y~y~y~y
	//			~c~c~c~c~c~c
	//			~m~m~m~m~m~m;

	//		vbo = Resource.CreateRes!Vbo("CubeData", Vbo.Rate.Rarely, vertices, colors);
	//	}


	//	m_renderTasks = new RenderTask(
	//		Resource.Get!Program("default.prg"),
	//		RenderTask.DrawMode.Triangle, 36, 
	//		"Cube", 
	//		vbo, true, null
	//	);
	//}
}


class Crate : Cube {
	mixin NodeCtor;
	//this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df sca=Vect3Df(1,1,1)){
	//	super(parent, pos, rot, sca);

	//	Texture texture = Resource.Get!Texture("crate.jpg");

	//	Vbo vbo;
	//	try vbo = Resource.Get!Vbo("CrateText");
	//	catch(ResourceException e){

	//		enum bl = [0.0,0.0];
	//		enum br = [1.0,0.0];
	//		enum tl = [0.0,1.0];
	//		enum tr = [1.0,1.0];

	//		float texturecoord[] = 
	//			 tr~br~bl~tr~bl~tl
	//			~br~tr~tl~br~tl~bl
	//			~tl~tr~br~tl~br~bl
	//			~tl~tr~br~tl~br~bl
	//			~tr~br~bl~tr~bl~tl
	//			~tr~br~bl~tr~bl~tl;

	//		vbo = Resource.CreateRes!Vbo("CrateText", Vbo.Rate.Rarely, texturecoord);
	//	}

	//	m_renderTasks[0] = new RenderTask(
	//		Resource.Get!Program("default.prg"),
	//		RenderTask.DrawMode.Triangle, 36, 
	//		"Cube",
	//		vbo, true, null
	//	);

	//	try m_vao = Resource.Get!Vao("Crate");
	//	catch(ResourceException e){
	//		m_vao = Resource.CreateRes!Vao("Crate", {
	//			m_vbo[0].Bind();
	//			glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[0]));
	//			glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[1]));
	//			glEnableVertexAttribArray(0);
	//			glEnableVertexAttribArray(1);
	//			m_vbo[1].Bind();
	//			glVertexAttribPointer(2, 2, GL_FLOAT, false, 0, cast(void*)(m_vbo[1].offset[0]));
	//			glEnableVertexAttribArray(2);
	//			Vbo.Unbind();

	//			texture.Bind();
	//		});
	//	}
	//}
}


class Axis : NodeModel {
	mixin NodeCtor;
//	this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df sca=Vect3Df(1,1,1)){
//		super(6, parent, pos, rot, sca);

//		drawMode = DrawMode.Line;
//		m_prog = Resource.Get!Program("default.prg");

//		try m_vbo ~= Resource.Get!Vbo("AxisData");
//		catch(ResourceException e){

//			float vertices[]= [	0,0,0, 1,0,0,
//								0,0,0, 0,1,0,
//								0,0,0, 0,0,1];

//			float verticesarrow[]= [
//				1,0,0, 0.9,0.05,0, 0.9,-0.05,0,
//				1,0,0, 0.9,-0.05,0, 0.9,0.05,0,
//				1,0,0, 0.9,0,0.05, 0.9,0,-0.05,
//				1,0,0, 0.9,0,-0.05, 0.9,0,0.05,

//				0,1,0, 0.05,0.9,0, -0.05,0.9,0,
//				0,1,0, -0.05,0.9,0, 0.05,0.9,0,
//				0,1,0, 0,0.9,0.05, 0,0.9,-0.05,
//				0,1,0, 0,0.9,-0.05, 0,0.9,0.05,

//				0,0,1, 0.05,0,0.9, -0.05,0,0.9,
//				0,0,1, -0.05,0,0.9, 0.05,0,0.9,
//				0,0,1, 0,0.05,0.9, 0,-0.05,0.9,
//				0,0,1, 0,-0.05,0.9, 0,0.05,0.9
//				];

//			enum r = [1,0,0];
//			enum g = [0,1,0];
//			enum b = [0,0,1];

//			float colors[] = r~r~g~g~b~b;
//			float colorsarrow[] =	r~r~r~ r~r~r~ r~r~r~ r~r~r~
//									g~g~g~ g~g~g~ g~g~g~ g~g~g~
//									b~b~b~ b~b~b~ b~b~b~ b~b~b;

//			m_vbo ~= Resource.CreateRes!Vbo("AxisData", Vbo.Rate.Rarely, vertices, colors, verticesarrow, colorsarrow);
//		}

//		try m_vao = Resource.Get!Vao("Axis");
//		catch(ResourceException e){
//			m_vao = Resource.CreateRes!Vao("Axis", {
//				m_vbo[0].Bind();
//				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[0]));
//				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[1]));
//				glEnableVertexAttribArray(0);
//				glEnableVertexAttribArray(1);
//				Vbo.Unbind();
//			});
//		}

//		try m_vaoarrow = Resource.Get!Vao("AxisArrow");
//		catch(ResourceException e){
//			m_vaoarrow = Resource.CreateRes!Vao("AxisArrow", {
//				m_vbo[0].Bind();
//				glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[2]));
//				glVertexAttribPointer(1, 3, GL_FLOAT, false, 0, cast(void*)(m_vbo[0].offset[3]));
//				glEnableVertexAttribArray(0);
//				glEnableVertexAttribArray(1);
//				Vbo.Unbind();
//			});
//		}
//	}

//	override void Render(ref mat4 proj, ref mat4 mdlview){
//		immutable pid = m_prog.id;
//		glUseProgram(pid);
//		m_vao.Bind();

//		//Send matrix
//		glUniformMatrix4fv(glGetUniformLocation(pid, "projection"), 1, true, proj.value_ptr);
//		glUniformMatrix4fv(glGetUniformLocation(pid, "modelview"), 1, true, mdlview.value_ptr);
		
//		//Render !    
//		glDrawArrays(m_drawmode, 0, m_vertexCount);

//		m_vaoarrow.Bind();

//		//Send matrix
//		glUniformMatrix4fv(glGetUniformLocation(pid, "projection"), 1, true, proj.value_ptr);
//		glUniformMatrix4fv(glGetUniformLocation(pid, "modelview"), 1, true, mdlview.value_ptr);
		
//		//Render !    
//		glDrawArrays(DrawMode.Triangle, 0, 3*12);

//		Vao.Unbind();
//		glUseProgram(0);
//	}

//private:
//	Vao m_vaoarrow;
}