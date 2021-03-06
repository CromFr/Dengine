module opengl.rendertask;

import gl3n.linalg;
import derelict.opengl3.gl3;
import resource;
import std.typecons;

public import opengl.program;
public import opengl.vbo;
public import opengl.vao;
public import opengl.texture;

/**
	Address of a data in a VBO
*/
alias VertexAddress = Tuple!(uint,"vboindex", uint,"dimension", uint,"destination");

/**
	An atomic rendering task
*/
class RenderTask{
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

	/**
		Creates a RenderTask with a program, drawmode and vertex count
	*/
	this(Program prg, in DrawMode drawMode, in uint vertexCount)
	in{
		assert(vertexCount>0, "RenderTasks with no vertex are not allowed");
	}body{
		m_prog = prg;
		m_drawMode = drawMode;
		m_vertexCount = vertexCount;
	}

	/**
		Associates the Task with VBO addresses containing the vertices/colors/texture coords/...
	*/
	void AssignVertex(Vbo vbo, VertexAddress[] links...){
		foreach(l ; links){
			m_vtxaddr ~= VertexAddressFull(vbo, l.vboindex, l.dimension, l.destination);
		}
	}

	/**
		The task will render a texture
	*/
	void AssignTexture(Texture texture){
		m_texture = texture;
	}

	/**
		Prepares the task to be rendered
		Must be called at the end of the RenderTask initialization
		Params:
			vaoName: The name of the associated VAO. If a VAO with the same name exists in the resource manager, it will use it. You can put "" to always create a new VAO.
	*/
	void Prepare(in string vaoName){
		ConstructVao(vaoName);
	}

	/**
		Renders the task
		Warning: The task must be prepared first !
	*/
	void Render(ref mat4 proj, ref mat4 mdlview)
	in{
		assert(m_prog !is null, "Program is null");
		assert(m_vertexCount>0, "0 vertex RenderTasks are not allowed");
		assert(m_vtxaddr.length>0, "No associated VBO");
		assert(m_vao !is null, "RenderTask must be prepared before rendering");
	}body{
		immutable pid = m_prog.id;
		m_prog.Bind();
		m_vao.Bind();

		glUniformMatrix4fv(glGetUniformLocation(pid, "projection"), 1, true, proj.value_ptr);
		glUniformMatrix4fv(glGetUniformLocation(pid, "modelview"), 1, true, mdlview.value_ptr);

		glDrawArrays(m_drawMode, 0, m_vertexCount);

		Vao.Unbind();
		Program.Unbind();
	}

	@property{
		DrawMode drawMode()const{return m_drawMode;}
		void drawMode(in DrawMode drawMode){m_drawMode = drawMode;}

		Program program(){return m_prog;}
		void program(Program p){m_prog = p;}
	}

protected:
	alias VertexAddressFull = Tuple!(Vbo,"vbo", uint,"vboindex", uint,"dimension", uint,"destination");

	void ConstructVao(in string vaoName){
		if(vaoName==""){
			m_vao = new Vao({
				//These lines will be executed on graphic card for each render

				Vbo lastVbo;
				foreach(va ; m_vtxaddr){
					if(va.vbo != lastVbo){
						lastVbo = va.vbo;
						va.vbo.Bind();
					}

					glVertexAttribPointer(va.destination, va.dimension, GL_FLOAT, false, 0, cast(void*)(va.vbo.offset[va.vboindex]));
					glEnableVertexAttribArray(va.destination);
				}
				Vbo.Unbind();

				if(m_texture !is null)
					m_texture.Bind();
			});
		}
		else{
			try m_vao = Resource.Get!Vao(vaoName);
			catch(ResourceException e){
				m_vao = Resource.CreateRes!Vao(vaoName, {
					//These lines will be executed on graphic card for each render

					Vbo lastVbo;
					foreach(va ; m_vtxaddr){
						if(va.vbo != lastVbo){
							lastVbo = va.vbo;
							va.vbo.Bind();
						}

						glVertexAttribPointer(va.destination, va.dimension, GL_FLOAT, false, 0, cast(void*)(va.vbo.offset[va.vboindex]));
						glEnableVertexAttribArray(va.destination);
					}
					Vbo.Unbind();

					if(m_texture !is null)
						m_texture.Bind();
				});
			}
		}
	}

	Program m_prog;
	const uint m_vertexCount;
	DrawMode m_drawMode;

	VertexAddressFull[] m_vtxaddr;
	Vao m_vao;

	Texture m_texture;

}