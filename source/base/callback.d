module base.callback;

import std.functional;

class Callback {

	void Execute(){
		foreach(ref dg ; m_dg){
			dg();
		}
	}

	//TODO operator (func) to append delegate
	//ex: Node.onRender(function(){...});

	size_t Call(void delegate() dg){
		m_dg[m_lastid++] = dg;
		return m_lastid-1;
	}

	size_t Call(void function() fun){
		return Call(toDelegate(fun));
	}

	void Remove(size_t id){
		m_dg[id].destroy();
	}

private:
	size_t m_lastid = 0;
	void delegate() m_dg[size_t];
}