module opengl.rendertask;

import gl3n.linalg;
import derelict.opengl3.gl3;
import resource;
import std.typecons;

public import opengl.program;
public import opengl.vbo;
public import opengl.vao;
public import opengl.texture;

alias VertexAddress = Tuple!(uint,"vboindex", uint,"dimension", uint,"destination");

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

	
	this(in Program prg, in DrawMode drawMode, in uint vertexCount){
		m_prog = prg;
		m_drawMode = drawMode;
		m_vertexCount = vertexCount;
	}

	
	void AssignVertex(Vbo vbo, VertexAddress[] links...){
		foreach(l ; links){
			m_vtxaddr ~= VertexAddressFull(vbo, l.vboindex, l.dimension, l.destination);
		}
	}

	void AssignTexture(Texture texture){
		m_texture = texture;
	}

	void Prepare(in string vaoName){
		ConstructVao(vaoName);
	}

	void Render(ref mat4 proj, ref mat4 mdlview){
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
		DrawMode drawMode(){return m_drawMode;}
		void drawMode(in DrawMode drawMode){m_drawMode = drawMode;}
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

	const Program m_prog;
	const uint m_vertexCount;
	DrawMode m_drawMode;

	bool m_bVaoConstructed = false;
	VertexAddressFull m_vtxaddr[];
	Vao m_vao;

	Texture m_texture;

}