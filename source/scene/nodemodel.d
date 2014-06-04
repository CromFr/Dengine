module scene.nodemodel;

public import scene.node;
public import opengl.program;
public import opengl.vao;
public import opengl.vbo;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

abstract class NodeModel : Node {
	this(uint vertexCount, Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0)) {
		super(parent, pos, rot);
		m_vertexCount = vertexCount;
	}

	enum DrawMode{
		Point=GL_POINTS,

		Line=GL_LINES,
		LineLoop=GL_LINE_LOOP,
		LineAdj=GL_LINES_ADJACENCY,
		LineStrip=GL_LINE_STRIP,
		LineStripAdj=GL_LINE_STRIP_ADJACENCY,

		Triangle=GL_TRIANGLES,
		TriangleAdg=GL_TRIANGLES_ADJACENCY,
		TriangleStrip=GL_TRIANGLE_STRIP,
		TriangleStripAdj=GL_TRIANGLE_STRIP_ADJACENCY,
		TriangleFan=GL_TRIANGLE_FAN,

		Patch=GL_PATCHES//TODO See how to use it (see glPatchParameteri(GL_PATCH_VERTICES, 16))
	}

	@property{
		DrawMode drawMode()const {return m_drawmode;}
		void drawMode(DrawMode dm){m_drawmode = dm;}
	}

	override void Render(ref mat4 proj, ref mat4 mdlview){
		immutable pid = m_prog.id;
		glUseProgram(pid);
		m_vao.Bind();

		//Send matrix
		glUniformMatrix4fv(glGetUniformLocation(pid, "projection"), 1, true, proj.value_ptr);
		glUniformMatrix4fv(glGetUniformLocation(pid, "modelview"), 1, true, mdlview.value_ptr);
		
		//Render !    
		glDrawArrays(m_drawmode, 0, m_vertexCount);

		Vao.Unbind();
		glUseProgram(0);
	}



protected:
	DrawMode m_drawmode = DrawMode.Triangle;
	Program m_prog;
	Vbo m_vbo[];
	uint m_vertexCount;
	Vao m_vao;
}