library earth_model;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Math,
  dglOpenGL;

{$R *.res}

type
  vertex_t = record
    x, y, z: GLfloat;
    u, v: GLfloat;
  end;
  
// Bigger values = better accuracy  
const
  NUMRINGS = 20;
  NUMSEGMENTS = 20;
    
procedure CreateSphere(const x, y, z: GLfloat; const radius: GLFloat);
var
  A: array of vertex_t;
  ring, seg: integer;
  fDeltaRingAngle: GLfloat;
  fDeltaSegAngle: GLfloat;
  ss, sc: GLfloat;
  r0, r1: GLfloat;
  x0, x1: GLfloat;
  y0, y1: GLfloat;
  z0, z1: GLfloat;
  idx: integer;
  segNumSegmentsU: GLfloat;
begin
  SetLength(A, 2 * NUMRINGS * (NUMSEGMENTS + 1));
  fDeltaRingAngle := pi / NUMRINGS;
  fDeltaSegAngle  := 2 * pi / NUMSEGMENTS;
   
  idx := 0;

  // Generate the group of rings for the sphere
  for ring := 0 to NUMRINGS - 1 do
  begin
    r0 := Sin(ring * fDeltaRingAngle);
    y0 := Cos(ring * fDeltaRingAngle);

    r1 := Sin((ring + 1) * fDeltaRingAngle);
    y1 := Cos((ring + 1) * fDeltaRingAngle);

    // Generate the group of segments for the current ring
    for seg := 0 to NUMSEGMENTS do
    begin
      ss := Sin(seg * fDeltaSegAngle);
      sc := Cos(seg * fDeltaSegAngle);
      x0 := r0 * ss;
      z0 := r0 * sc;
      x1 := r1 * ss;
      z1 := r1 * sc;

      segNumSegmentsU := seg / NUMSEGMENTS;

      A[idx].x := x0;
      A[idx].y := y0;
      A[idx].z := z0;
      A[idx].v := ring / NUMRINGS;
      A[idx].u := segNumSegmentsU;
      inc(idx);

      A[idx].x := x1;
      A[idx].y := y1;
      A[idx].z := z1;
      A[idx].v := (1 + ring) / NUMRINGS;
      A[idx].u := segNumSegmentsU;
      inc(idx);
    end;
  end;

  for idx := 0 to Length(A) - 1 do
  begin
    A[idx].x := (A[idx].x * radius) + x;
    A[idx].y := (A[idx].y * radius) + y;
    A[idx].z := (A[idx].z * radius) + z;
  end;

  glbegin(GL_TRIANGLE_STRIP);
  for idx := 0 to Length(A) - 1 do
  begin
    glTexCoord2f(A[idx].u, A[idx].v);
    glVertex3f(A[idx].x, A[idx].y, A[idx].z);
  end;
  glEnd;

  SetLength(A, 0);
end;

function draw(const frm1, frm2: integer; const offs: GLfloat): boolean; stdcall;
var
  rot: GLfloat;
  f1, f2: integer;
begin
  f1 := abs(frm1 mod 360);
  f2 := abs(frm2 mod 360);
  if f1 > f2 then
    f2 := f2 + 360;

  rot := f1 * offs + f2 * (1.0 - offs);
  if rot >= 360.0 then
    rot := rot - 360.0;

  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glRotatef(rot , 0.0, 1.0, 0.0);
  CreateSphere(0, 0.25, 0, 0.25);
  glPopMatrix;
  Result := True;
end;

exports
  draw;

begin
  InitOpenGL;
  ReadOpenGLCore;
end.
