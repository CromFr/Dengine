import std.stdio;
import std.conv;
import std.string;
import std.traits;
import core.thread;

import engine;
import scene.baseshapes;
import opengl.shader;
import opengl.program;
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

	//CompileShaders();
	auto tetra = new Tetrahedron(eng.rootNode, Vect3Df(1,0,-5));

	tetra.onUpdated.Add(delegate(){
		tetra.RotateX(1);
		tetra.RotateZ(1);
	});

	auto cube = new Cube(eng.rootNode, Vect3Df(-1,0,-5));
	cube.onUpdated.Add(delegate(){
		cube.RotateX(-1);
		cube.RotateZ(-1);
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