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
	tetra.onUpdated.Call((float sec){
		tetra.RotateX(90.0*sec);
		tetra.RotateZ(90.0*sec);
	});

	Cube cube = new Cube(eng.rootNode, Vect3Df(-2,0,-5));
	cube.onUpdated.Call((float sec){
		cube.RotateX(-9.0*sec);
		cube.RotateZ(-9.0*sec);
	});
	auto cube2 = new Cube(cube, Vect3Df(1.0,0,0), Quatf.identity, Vect3Df(0.5,0.5,0.5));

	auto crate = new Crate(eng.rootNode, Vect3Df(0,0,-5));
	crate.onUpdated.Call((float sec){
		static bool b = false;
		static int n = 0;
		crate.RotateY(2*sec);
		if(!b){
			crate.RotateX(3.0*sec);
			n++;
			if(n==150)
				b=true;
		}
		else{
			crate.RotateX(-3.0*sec);
			n--;
			if(n==-150)
				b=false;
		}
	});

	auto axis = new Axis(eng.rootNode, Vect3Df(0,1,-5));
	axis.onUpdated.Call((float sec){
		axis.RotateX(sec*(-9.0));
		axis.RotateZ(sec*(-9.0));
	});

	auto teapot = new Teapot(eng.rootNode, Vect3Df(2,1,-5), Quatf.identity, Vect3Df(0.01,0.01,0.01));
	teapot.onUpdated.Call((float sec){
		teapot.RotateY(30.0*sec);
	});


	bool bRun=true;
	bool bPause=false;
	while(bRun){
		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
				case SDL_QUIT:
					bRun = false;
					break;
				case SDL_MOUSEBUTTONDOWN:
					bPause = !bPause;
					break;
				default:
					break;
			}
		}
		if(!bPause)
			eng.Update();
		eng.Render();

		Thread.sleep(dur!"msecs"(10));
	}


}