module opengl.model;

import std.path;
import gl3n.linalg;
import opengl.rendertask;
import tools.objloader;
import std.file: DirEntry;

class Model{
	this(DirEntry file){
		immutable string ext = extension(file);
		switch(ext){
			case ".obj":
				m_renderTasks = (new ObjLoader(file)).GetRenderTasks();
				break;

			default:
				throw new Exception(ext~" format not handled");
		}

		//call loader for file extension
	}
	this(RenderTask[] renderTasks...){
		m_renderTasks = renderTasks;
	}

	ref RenderTask[] tasks(){return m_renderTasks;}

	void Render(ref mat4 proj, ref mat4 mdlview){
		foreach(rt ; m_renderTasks){
			rt.Render(proj, mdlview);
		}
	}

private:
	RenderTask[] m_renderTasks;
}