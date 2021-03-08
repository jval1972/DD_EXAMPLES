library proctree;

uses
  dglOpenGL,
  proctree_kernel in 'proctree_kernel.pas';

procedure glRenderFaces(const mVertCount, mFaceCount: integer;
  const mVert, mNormal: array of fvec3_t; const mUV: array of fvec2_t;
  const mFace: array of ivec3_t);
var
  i: integer;
  procedure _render_rover(const r: integer);
  begin
    glTexCoord2f(mUV[r].u, mUV[r].v);
    glvertex3f(mVert[r].x, mVert[r].y, mVert[r].z);
  end;
begin
  glBegin(GL_TRIANGLES);
    for i := 0 to mFaceCount - 1 do
    begin
      _render_rover(mFace[i].x);
      _render_rover(mFace[i].y);
      _render_rover(mFace[i].z);
    end;
  glEnd;
end;

function glRenderTrunk(const id: integer): boolean;
var
  t: tree_t;
begin
  if (id < 0) or (id >= NUMTREES) then
  begin
    Result := False;
    Exit;
  end;

  t := TREES[id];
  glRenderFaces(t.mVertCount, t.mFaceCount, t.mVert, t.mNormal, t.mUV, t.mFace);
  Result := True;
end;

function glRenderTwig(const id: integer): boolean;
var
  t: tree_t;
begin
  if (id < 0) or (id >= NUMTREES) then
  begin
    Result := False;
    Exit;
  end;

  t := TREES[id];
  glRenderFaces(t.mTwigVertCount, t.mTwigFaceCount, t.mTwigVert, t.mTwigNormal, t.mTwigUV, t.mTwigFace);
  Result := True;
end;

function draw(const frm1, frm2: integer; const offs: GLfloat): boolean; stdcall;
begin
  if frm1 < 1000 then
    Result := glRenderTrunk(frm1)
  else
    Result := glRenderTwig(frm1 - 1000);
end;

exports
  draw;

begin
  InitOpenGL;
  ReadOpenGLCore;
end.
