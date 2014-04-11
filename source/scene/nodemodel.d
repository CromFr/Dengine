module scene.nodemodel;

public import scene.node;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

abstract class NodeModel : Node {
	mixin NodeCtor;

	override void Render(ref mat4 proj, ref mat4 mdlview){
	}

protected:
	float m_vertices[];
	float m_colors[];
}