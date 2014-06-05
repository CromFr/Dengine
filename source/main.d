import std.stdio;
import std.conv;
import std.string;
import std.traits;
import core.thread;

import engine;
import scene.baseshapes;
import opengl.shader;
import opengl.program;
import opengl.texture;
import resource;
	
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

void main()
{
	version(unittest)
		writeln("\x1b[1m\x1b[42m==========> UNITTEST SUCCESS, well done !\x1b[m");

	auto eng = new Engine;
	Resource.LoadFromFiles!Shader("res/shaders", "*.vtx", true, ShaderType.Vertex);
	Resource.LoadFromFiles!Shader("res/shaders", "*.frg", true, ShaderType.Fragment);
	Resource.LoadFromFiles!Program("res/shaders", "*.prg", true);

	Resource.LoadFromFiles!Texture("res/material", "*", true);

	auto tetra = new Tetrahedron(eng.rootNode, Vect3Df(2,0,-5));
	tetra.onUpdated.Call({
		tetra.RotateX(1);
		tetra.RotateZ(1);
	});

	Cube cube = new Cube(eng.rootNode, Vect3Df(-2,0,-5));
	cube.onUpdated.Call({
		cube.RotateX(-1);
		cube.RotateZ(-1);
	});
	auto cube2 = new Cube(cube, Vect3Df(1.0,0,0), Vect3Df(0,0,0), Vect3Df(0.5,0.5,0.5));

	auto crate = new Crate(eng.rootNode, Vect3Df(0,0,-5));
	crate.onUpdated.Call({
		static bool b = false;
		static int n = 0;
		crate.RotateY(0.2);
		if(!b){
			crate.RotateX(0.3);
			n++;
			if(n==150)
				b=true;
		}
		else{
			crate.RotateX(-0.3);
			n--;
			if(n==-150)
				b=false;
		}
	});

	auto axis = new Axis(eng.rootNode, Vect3Df(0,1,-5));
	axis.onUpdated.Call({
		axis.RotateX(-0.1);
		axis.RotateZ(-0.1);
	});


	bool bRun=true;
	while(bRun){
		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
				case SDL_QUIT:
					bRun = false;
					break;
				default:
					break;
			}
		}
		eng.Update();
		eng.Render();

		Thread.sleep(dur!"msecs"(10));
	}


}