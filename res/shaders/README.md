# Shaders

- .frg : Fragment shader
- .vtx : Vertex shader
- .prg : Program definition (links vertex & fragment shaders)

# Program definition:

```json
{
	"shaders": ["shader1", "shader2", ...],
	"binds":{
		"0": "Var0",
		"1": "Var1",
		...
		"n": "Varn"
	}
}
```

# Program reserved slots:

Program Slot|Use
:---:|:---
0|Vertices
1|Colors
2|Texture coordinates
3|Normals
