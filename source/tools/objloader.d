module tools.objloader;

import std.file;
import std.regex;
import std.stream;
import std.conv : to;
import opengl.rendertask;
import resource;
import std.string : split;

import std.stdio;

class ObjLoader{

	this(in DirEntry file){
		Parse(file);
	}

	RenderTask[] GetRenderTasks(){
		RenderTask[] ret;

		foreach(o ; m_objects){

			foreach(g ; o.groups){

				//Prepare Data
				float[] vertices;
				float[] txtcoords;
				float[] normals;

				//fall to default if value is impossible
				pure ref uint FallDef(ref uint i, ref uint defIndex){
					if(i==i.max)
						return defIndex;
					return i;
				}

				foreach(f ; g.faces){
					vertices ~=
							 g.vertices[f[0]-1]//xyz
							~g.vertices[f[3]-1]//xyz
							~g.vertices[f[6]-1];//xyz

					if(m_bHasTxtCoords){
						txtcoords ~=
							 g.txtcoords[ FallDef(f[1],f[0])-1 ]
							~g.txtcoords[ FallDef(f[4],f[3])-1 ]
							~g.txtcoords[ FallDef(f[7],f[6])-1 ];
					}
					//else{
					//	txtcoords ~= [g.vertices[f[0]-1][0]/100.0, g.vertices[f[0]-1][2]/100.0]
					//				~[g.vertices[f[3]-1][0]/100.0, g.vertices[f[3]-1][2]/100.0]
					//				~[g.vertices[f[6]-1][0]/100.0, g.vertices[f[6]-1][2]/100.0];
					//}

					if(m_bHasNormals){
						normals ~=
							 g.normals[ FallDef(f[2],f[0])-1 ]
							~g.normals[ FallDef(f[5],f[3])-1 ]
							~g.normals[ FallDef(f[8],f[6])-1 ];
					}
				}

				//Use a unique VBO
				auto vbo = new Vbo(Vbo.Rate.Rarely, vertices, txtcoords, normals);


				//RenderTask
				auto rt = new RenderTask(
					Resource.Get!Program("texture.prg"),
					RenderTask.DrawMode.Triangle, cast(uint)(g.faces.length*3)
				);
				rt.AssignVertex(vbo,
					VertexAddress(0, 3, 0),
					VertexAddress(1, 2, 2)
				);

				rt.AssignTexture(Resource.Get!Texture("iron.jpg"));

				rt.Prepare("");

				ret ~= rt;
			}
		}


		return ret;
	}

private:
	enum rgxComment = ctRegex!(r"^\s*#.*?$");
	enum rgxVertex = ctRegex!(r"^\s*v((\s+[0-9\.eE\-]+){3,4})\s*$");
	enum rgxNormal = ctRegex!(r"^\s*vn((\s+[0-9\.eE\-]+){3})\s*$");
	enum rgxTxtCoord = ctRegex!(r"^\s*vt((\s+[0-9\.eE\-]+){2,3})\s*$");
	enum rgxFace = ctRegex!(r"^\s*f((\s+[0-9/]+){3})\s*$");


	enum rgxObject = ctRegex!(r"^\s*o\s+(.+)\s*$");
	enum rgxGroup = ctRegex!(r"^\s*g\s+(.+)\s*$");


	struct Object{
		string name;
		Group[] groups;
	}

	struct Group{
		string name;

		float[3][] vertices;
		float[3][] normals;
		float[2][] txtcoords;
		uint[9][] faces;
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
				m_bHasVertices = true;

				string[] s = r[1].split;
				float[4] val = to!(float[])(s[0..3])~(s.length==4 ? to!float(s[3]) : 1.0);

				grp.vertices ~= val[0..3];//We do not use 4th value
				continue;
			}

			r=matchFirst(line, rgxNormal);
			if(r){
				m_bHasNormals = true;

				string[] s = r[1].split;

				grp.normals ~= to!(float[])(s[])[0..3];//We do not use 4th value
				continue;
			}

			r=matchFirst(line, rgxTxtCoord);
			if(r){
				m_bHasTxtCoords = true;

				string[] s = r[1].split;
				float[3] val = to!(float[])(s[0..2])~(s.length==3 ? to!float(s[2]) : 0.0);

				grp.txtcoords~=val[0..2];//We do not use 3rd value
				continue;
			}

			r=matchFirst(line, rgxFace);
			if(r){
				m_bHasFaces=true;

				uint[] val;

				string[] s = r[1].split;
				foreach(si ; 0..3){
					string[] ss = s[si].split("/");
					ss.length = 3;

					foreach(ref ssv ; ss){
						if(ssv=="")
							val ~= uint.max;
						else
							val ~= to!(uint)(ssv);
					}
				}
				grp.faces~=val[0..9];
				continue;
			}
		}

		obj.groups~=grp;
		m_objects~=obj;



		stream.close();
	}


	Object[] m_objects;
	bool m_bHasVertices = false;
	bool m_bHasNormals = false;
	bool m_bHasTxtCoords = false;
	bool m_bHasFaces = false;

}