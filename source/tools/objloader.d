module tools.objloader;

import std.file;
import std.regex;
import std.stream;
import std.conv : to;
import opengl.rendertask;
import resource;

import std.stdio;

class ObjLoader{

	this(in DirEntry file){
		Parse(file);

	}

	RenderTask[] GetRenderTasks(){
		RenderTask ret[];

		foreach(o ; m_objects){

			foreach(g ; o.groups){
				writeln("Vertices=",g.vertices.length);
				writeln("Faces=",g.faces.length);
				

				//Prepare Data
				float vertices[];
				float normals[];
				float txtcoords[];

				foreach(f ; g.faces){
					vertices ~= g.vertices[f[2]-1]~g.vertices[f[1]-1]~g.vertices[f[0]-1];
				}

				//Use a unique VBO
				auto vbo = new Vbo(Vbo.Rate.Rarely, vertices);


				//RenderTask
				auto rt = new RenderTask(
					Resource.Get!Program("texture.prg"),
					RenderTask.DrawMode.Triangle, cast(uint)(g.faces.length*3)
				);
				rt.AssignVertex(vbo, 
					VertexAddress(0, 3, 0)
				);
				rt.Prepare("");

				ret ~= rt;
			}
		}


		return ret;
	}

	void dbg(){
		writeln("vertices: ",m_objects[0].groups[0].vertices.length);
		writeln("normals: ",m_objects[0].groups[0].normals.length);
		writeln("txtcoords: ",m_objects[0].groups[0].txtcoords.length);
		writeln("faces: ",m_objects[0].groups[0].faces.length);
	}
	
private://?P<name>
	enum rgxComment = ctRegex!(r"^#.*$");
	enum rgxVertex = ctRegex!(r"^v\s+([0-9\.eE\-]+)\s+([0-9\.eE\-]+)\s+([0-9\.eE\-]+)\s*$");
	// ^v\s+([0-9\.eE\-]+)\s+([0-9\.eE\-]+)\s+([0-9\.eE\-]+)(\s+([0-9\.eE\-]+))?\s*$
	enum rgxNormal = ctRegex!(r"^vn\s+([0-9\.eE\-]+)\s+([0-9\.eE\-]+)\s+([0-9\.eE\-]+)\s*$");
	enum rgxTxtCoord = ctRegex!(r"^vt\s+([0-9\.eE\-]+)\s+([0-9\.eE\-]+)$");
	enum rgxFace = ctRegex!(r"^f\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s*$");


	enum rgxObject = ctRegex!(r"^o\s+(.+)$");
	enum rgxGroup = ctRegex!(r"^g\s+(.+)$");


	struct Object{
		string name;
		Group groups[];
	}

	struct Group{
		string name;

		float vertices[][3];
		float normals[][3];
		float txtcoords[][2];
		uint faces[][3];
	}



	void Parse(in DirEntry file){
		Stream stream = new BufferedFile(file);

		Object obj = Object("");
		Group grp = Group("");
		while(!stream.eof())
		{
			immutable string line = stream.readLine().idup;
			Captures!string r;

			
			if(line==""){
				continue;
			}

			r=matchFirst(line, rgxComment);
			if(r)
				continue;

			r=matchFirst(line, rgxObject);
			if(r){
				if(obj.name!="")
					m_objects~=obj;
				obj = Object(r[1]);
				continue;
			}
			
			r=matchFirst(line, rgxGroup);
			if(r){
				if(grp.name!="")
					obj.groups~=grp;
				grp = Group(r[1]);
				continue;
			}

			r=matchFirst(line, rgxVertex);
			if(r){
				grp.vertices~=[to!float(r[1]), to!float(r[2]), to!float(r[3])];
				continue;
			}

			r=matchFirst(line, rgxNormal);
			if(r){
				grp.normals~=[to!float(r[1]), to!float(r[2]), to!float(r[3])];
				continue;
			}

			r=matchFirst(line, rgxTxtCoord);
			if(r){
				grp.txtcoords~=[to!float(r[1]), to!float(r[2])];
				continue;
			}

			r=matchFirst(line, rgxFace);
			if(r){
				grp.faces~=[to!uint(r[1]), to!uint(r[2]), to!uint(r[3])];
				continue;
			}
		}

		obj.groups~=grp;
		m_objects~=obj;



		stream.close();
	}


	Object m_objects[];

}