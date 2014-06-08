module opengl.texture;

import std.file : DirEntry;
import std.string : toStringz;
import std.conv;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

/**
	Exception thrown when dealing with the Texture class
*/
class TextureException : Exception{
	enum Type{
		Format
	}

	this(in string _msg, in Type _type, in string _filepath){
		type = _type;
		filepath = _filepath;

		super("OpenGL Texture "~to!string(type)~" exception@"~filepath~" "~_msg);
	}

	immutable Type type;
	immutable string filepath;
}

/**
	Load the texture from file to render it on an object
*/
class Texture {

	/**
		Creates the texture from a file. Supported formats are the same that sdl-image
	*/
	this(DirEntry file) {
		m_filepath = file.name;

		m_surf = IMG_Load(file.name.toStringz);
		if(m_surf==null){
			throw new TextureException(to!string(SDL_GetError()), TextureException.Type.Format, m_filepath);
		}

		//Allocate texture
		glGenTextures(1, &m_id);

		//Bind it to use it
		glBindTexture(GL_TEXTURE_2D, m_id);

		if(m_surf.format.BytesPerPixel == 3)
		{
			m_intformat = GL_RGB;
		    if(m_surf.format.Rmask == 0xff)
		        m_format = GL_RGB;
		    else
		        m_format = GL_BGR;
		}
		else if(m_surf.format.BytesPerPixel == 4)
		{
			m_intformat = GL_RGBA;
		    if(m_surf.format.Rmask == 0xff)
		        m_format = GL_RGBA;
		    else
		        m_format = GL_BGRA;
		}
		else
			throw new TextureException("Unknown texture format", TextureException.Type.Format, m_filepath);


		//void glTexImage2D(GLenum target,  GLint level,  GLint internalFormat,  GLsizei width,  GLsizei height,  GLint border,  GLenum format,  GLenum type,  const GLvoid * data);
		glTexImage2D(GL_TEXTURE_2D, 0, m_intformat, m_surf.w, m_surf.h, 0, m_format, GL_UNSIGNED_BYTE, m_surf.pixels);
	
		//Apply filters
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

		//Unbind texture
		glBindTexture(GL_TEXTURE_2D, 0);

		SDL_FreeSurface(m_surf);
	}
	~this(){
		glDeleteTextures(1, &m_id);
	}

	/**
		Activates the texture for rendering
	*/
	void Bind()const{
		glBindTexture(GL_TEXTURE_2D, m_id);
	}

	/**
		Deactivates the texture for rendering
	*/
	static void Unbind(){
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	/**
		OpenGL Object ID
	*/
	@property{
		uint id() const{return m_id;}
	}



private:
	immutable string m_filepath;

	SDL_Surface* m_surf = null;
	immutable uint m_format, m_intformat;
	uint m_id;
}