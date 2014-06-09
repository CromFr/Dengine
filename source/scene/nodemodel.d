module scene.nodemodel;

public import scene.node;
public import opengl.program;
public import opengl.vao;
public import opengl.vbo;
public import opengl.rendertask;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

abstract class NodeModel : Node {
	mixin NodeCtor;

	override void Render(ref mat4 proj, ref mat4 mdlview){
		foreach(rt ; m_renderTasks){
			rt.Render(proj, mdlview);
		}
	}



protected:
	RenderTask[] m_renderTasks;
}