module resource;
import std.file : DirEntry, dirEntries, SpanMode;
import std.string : chompPrefix;

class Resource{
static:
	/**
		Add a resource to the manager
	*/
	void AddRes(T)(in string sName, ref T res){
		TypeInfo ti = typeid(T);
		if(!(ti in m_loadedRes && sName in m_loadedRes[ti]))
			m_loadedRes[typeid(T)][sName] = res;
		else
			throw new Exception("Resource '"~sName~"' not found");
	}

	/**
		Gets the resource with its name
	*/
	ref T Get(T)(string sName){
		TypeInfo ti = typeid(T);
		if(ti in m_loadedRes && sName in m_loadedRes[ti])
			return *(cast(T*)&(m_loadedRes[ti][sName]));

		throw new Exception("Resource '"~sName~"' not found");
	}

	/**
		Loads the resources contained in directory matching filePatern
		The first argument of the resource constructor must be a DirEntry, followed by any arguments provided with ctorArgs
	*/
	void LoadFromFiles(T, VT...)(in string directory, in string filePatern, in bool recursive, VT ctorArgs){
		foreach(ref file ; dirEntries(directory, filePatern, recursive?SpanMode.depth:SpanMode.shallow)){
			if(file.isFile){
				T res = new T(file, ctorArgs);
				AddRes!T(file.name.chompPrefix(directory~"/"), res);
			}
		}
	}

private:
	this(){}
	__gshared Object[string][TypeInfo] m_loadedRes;
}


unittest {
	import std.stdio;
	import std.file;
	static class Foo{
		this(){}
		this(DirEntry file, int i){s = file.name;}
		string s = "goto bar";
	}

	auto rm = new Resource;

	auto foo = new Foo;
	rm.AddRes("yolo", foo);

	assert(rm.Get!Foo("yolo") == foo);
	assert(rm.Get!Foo("yolo") is foo);

	rm.LoadFromFiles!Foo(".", "dub.json", false, 5);
	assert(rm.Get!Foo("dub.json") !is null);

	auto fe = new FileException("ahahaha");
	rm.AddRes("Boom headshot", fe);
}