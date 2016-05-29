module engine;

import std.stdio;
import std.math;
import std.conv: to;
import std.datetime: TickDuration;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl3;
import gl3n.linalg;

import scene.nodecontainer;

class Engine {
	this() {
		Node nullnode = null;
		m_rootnode = new NodeContainer(nullnode);

		//Load libs
		DerelictGL3.load();
		DerelictSDL2.load();
		DerelictSDL2Image.load();

		//Init SDL
		SDL_Init(SDL_INIT_VIDEO);
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

		m_win = SDL_CreateWindow("3D Engine by Crom",
					SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
					1024, 768, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);

		//SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
		//SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
		SDL_GLContext ctx = SDL_GL_CreateContext(m_win);

		//Write OpenGL Version
		writeln("OpenGL version: ", glGetString(GL_VERSION).to!string);
		writeln("OpenGL renderer: ", glGetString(GL_RENDERER).to!string);
		writeln("OpenGL vendor: ", glGetString(GL_VENDOR).to!string);

		DerelictGL3.reload();

		glEnable(GL_DEPTH_TEST);
		glClearColor(0.5, 0.5, 0.5, 1.0);

		//Calculate projection matrix
		m_proj = ProjMat(70.0, 4.0/3.0, 1.0, 100.0);

	}
	this(ref Node rootnode){
		this();
		m_rootnode = rootnode;
	}

	void Update(){
		m_rootnode.Update(true);
	}
	void Render(){
		//Pre-render
		m_mdlview.make_identity();

		//Render
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		m_rootnode.EngineRender(m_proj, m_mdlview);
		SDL_GL_SwapWindow(m_win);
	}

	@property{
		ref Node rootNode(){return m_rootnode;}
		void rootNode(ref Node rootnode){m_rootnode = rootnode;}
	}

	void LimitFramerate(float frameRateHz){
		static TickDuration lastRender = TickDuration.zero;
		if(lastRender==TickDuration.zero)
			lastRender = TickDuration.currSystemTick;

		immutable period = TickDuration((TickDuration.ticksPerSec/frameRateHz).to!long);
		auto duration = period-(TickDuration.currSystemTick - lastRender);

		if(duration.length>0){
			import core.thread;
			Thread.sleep(cast(Duration)duration);
		}
		lastRender = TickDuration.currSystemTick;
	}


private:
	SDL_Window* m_win;
	Node m_rootnode;

	mat4 m_proj, m_mdlview;


	mat4 ProjMat(float fFov, float fRatio, float fNear, float fFar){
		float f = 1/tan(PI*fFov/360);
		return mat4(
			f/fRatio,0,0,0,
			0,f,0,0,
			0,0,(fNear+fFar)/(fNear-fFar),2*fNear*fFar/(fNear-fFar),
			0,0,-1,0
		);
	}



}