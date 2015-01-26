module base.callback;

import std.functional;

class Callback(Args...) {

	void Execute(Args args){
		foreach(ref dg ; m_dg){
			dg(args);
		}
	}

	//TODO operator (func) to append delegate
	//ex: Node.onRender(function(){...});

	size_t Call(void delegate(Args) dg){
		m_dg[m_lastid++] = dg;
		return m_lastid-1;
	}

	size_t Call(void function(Args) fun){
		return Call(toDelegate(fun));
	}

	void Remove(size_t id){
		m_dg[id].destroy();
	}

private:
	size_t m_lastid = 0;
	void delegate(Args) m_dg[size_t];
}