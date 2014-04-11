import std.stdio;
import std.conv;
import std.string;
import std.traits;
import core.thread;

import engine;
import scene.testcube;
import opengl.shader;
import opengl.program;
import resource;
	
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

void main()
{
	auto eng = new Engine;
	Resource.LoadFromFiles!Shader("res/shaders", "*.vtx", true, ShaderType.Vertex);
	Resource.LoadFromFiles!Shader("res/shaders", "*.frg", true, ShaderType.Fragment);
	Resource.LoadFromFiles!Program("res/shaders", "*.prg", true);

	//CompileShaders();
	auto cube = new TestCube(eng.rootNode, Vect3Df(0,0,-2));

	cube.onUpdated.Add(delegate(){
		cube.Move(Vect3Df(0.002, 0.0 ,0.0));
		cube.RotateX(1);
		cube.RotateY(1);
		cube.RotateZ(1);
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