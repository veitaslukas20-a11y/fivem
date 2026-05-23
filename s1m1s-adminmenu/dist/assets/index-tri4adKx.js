(function() {
  const t = document.createElement("link").relList;
  if (t && t.supports && t.supports("modulepreload")) return;
  for (const o of document.querySelectorAll('link[rel="modulepreload"]')) r(
  o);
  new MutationObserver(o => {
    for (const l of o)
      if (l.type === "childList")
        for (const n of l.addedNodes) n.tagName === "LINK" && n.rel ===
          "modulepreload" && r(n)
  }).observe(document, {
    childList: !0,
    subtree: !0
  });

  function s(o) {
    const l = {};
    return o.integrity && (l.integrity = o.integrity), o.referrerPolicy && (l
        .referrerPolicy = o.referrerPolicy), o.crossOrigin ===
      "use-credentials" ? l.credentials = "include" : o.crossOrigin ===
      "anonymous" ? l.credentials = "omit" : l.credentials = "same-origin", l
  }

  function r(o) {
    if (o.ep) return;
    o.ep = !0;
    const l = s(o);
    fetch(o.href, l)
  }
})();
/**
 * @vue/shared v3.4.27
 * (c) 2018-present Yuxi (Evan) You and Vue contributors
 * @license MIT
 **/
/*! #__NO_SIDE_EFFECTS__ */
function Ds(e, t) {
  const s = new Set(e.split(","));
  return r => s.has(r)
}
const G = {},
  dt = [],
  we = () => {},
  Xr = () => !1,
  ss = e => e.charCodeAt(0) === 111 && e.charCodeAt(1) === 110 && (e.charCodeAt(
    2) > 122 || e.charCodeAt(2) < 97),
  Ls = e => e.startsWith("onUpdate:"),
  re = Object.assign,
  Vs = (e, t) => {
    const s = e.indexOf(t);
    s > -1 && e.splice(s, 1)
  },
  Zr = Object.prototype.hasOwnProperty,
  R = (e, t) => Zr.call(e, t),
  F = Array.isArray,
  ft = e => Ot(e) === "[object Map]",
  xt = e => Ot(e) === "[object Set]",
  fo = e => Ot(e) === "[object Date]",
  I = e => typeof e == "function",
  Q = e => typeof e == "string",
  De = e => typeof e == "symbol",
  J = e => e !== null && typeof e == "object",
  qo = e => (J(e) || I(e)) && I(e.then) && I(e.catch),
  Go = Object.prototype.toString,
  Ot = e => Go.call(e),
  Qr = e => Ot(e).slice(8, -1),
  Jo = e => Ot(e) === "[object Object]",
  Ns = e => Q(e) && e !== "NaN" && e[0] !== "-" && "" + parseInt(e, 10) === e,
  kt = Ds(
    ",key,ref,ref_for,ref_key,onVnodeBeforeMount,onVnodeMounted,onVnodeBeforeUpdate,onVnodeUpdated,onVnodeBeforeUnmount,onVnodeUnmounted"
    ),
  os = e => {
    const t = Object.create(null);
    return s => t[s] || (t[s] = e(s))
  },
  el = /-(\w)/g,
  $e = os(e => e.replace(el, (t, s) => s ? s.toUpperCase() : "")),
  tl = /\B([A-Z])/g,
  ct = os(e => e.replace(tl, "-$1").toLowerCase()),
  rs = os(e => e.charAt(0).toUpperCase() + e.slice(1)),
  gs = os(e => e ? `on${rs(e)}` : ""),
  it = (e, t) => !Object.is(e, t),
  Kt = (e, t) => {
    for (let s = 0; s < e.length; s++) e[s](t)
  },
  Yo = (e, t, s, r = !1) => {
    Object.defineProperty(e, t, {
      configurable: !0,
      enumerable: !1,
      writable: r,
      value: s
    })
  },
  Yt = e => {
    const t = parseFloat(e);
    return isNaN(t) ? e : t
  };
let ho;
const Xo = () => ho || (ho = typeof globalThis < "u" ? globalThis :
  typeof self < "u" ? self : typeof window < "u" ? window : typeof global <
  "u" ? global : {});

function Le(e) {
  if (F(e)) {
    const t = {};
    for (let s = 0; s < e.length; s++) {
      const r = e[s],
        o = Q(r) ? ll(r) : Le(r);
      if (o)
        for (const l in o) t[l] = o[l]
    }
    return t
  } else if (Q(e) || J(e)) return e
}
const sl = /;(?![^(]*\))/g,
  ol = /:([^]+)/,
  rl = /\/\*[^]*?\*\//g;

function ll(e) {
  const t = {};
  return e.replace(rl, "").split(sl).forEach(s => {
    if (s) {
      const r = s.split(ol);
      r.length > 1 && (t[r[0].trim()] = r[1].trim())
    }
  }), t
}

function Z(e) {
  let t = "";
  if (Q(e)) t = e;
  else if (F(e))
    for (let s = 0; s < e.length; s++) {
      const r = Z(e[s]);
      r && (t += r + " ")
    } else if (J(e))
      for (const s in e) e[s] && (t += s + " ");
  return t.trim()
}
const il =
  "itemscope,allowfullscreen,formnovalidate,ismap,nomodule,novalidate,readonly",
  nl = Ds(il);

function Zo(e) {
  return !!e || e === ""
}

function al(e, t) {
  if (e.length !== t.length) return !1;
  let s = !0;
  for (let r = 0; s && r < e.length; r++) s = nt(e[r], t[r]);
  return s
}

function nt(e, t) {
  if (e === t) return !0;
  let s = fo(e),
    r = fo(t);
  if (s || r) return s && r ? e.getTime() === t.getTime() : !1;
  if (s = De(e), r = De(t), s || r) return e === t;
  if (s = F(e), r = F(t), s || r) return s && r ? al(e, t) : !1;
  if (s = J(e), r = J(t), s || r) {
    if (!s || !r) return !1;
    const o = Object.keys(e).length,
      l = Object.keys(t).length;
    if (o !== l) return !1;
    for (const n in e) {
      const i = e.hasOwnProperty(n),
        u = t.hasOwnProperty(n);
      if (i && !u || !i && u || !nt(e[n], t[n])) return !1
    }
  }
  return String(e) === String(t)
}

function Hs(e, t) {
  return e.findIndex(s => nt(s, t))
}
const k = e => Q(e) ? e : e == null ? "" : F(e) || J(e) && (e.toString === Go ||
    !I(e.toString)) ? JSON.stringify(e, Qo, 2) : String(e),
  Qo = (e, t) => t && t.__v_isRef ? Qo(e, t.value) : ft(t) ? {
    [`Map(${t.size})`]: [...t.entries()].reduce((s, [r, o], l) => (s[bs(r, l) +
      " =>"] = o, s), {})
  } : xt(t) ? {
    [`Set(${t.size})`]: [...t.values()].map(s => bs(s))
  } : De(t) ? bs(t) : J(t) && !F(t) && !Jo(t) ? String(t) : t,
  bs = (e, t = "") => {
    var s;
    return De(e) ? `Symbol(${(s=e.description)!=null?s:t})` : e
  };
/**
 * @vue/reactivity v3.4.27
 * (c) 2018-present Yuxi (Evan) You and Vue contributors
 * @license MIT
 **/
let ke;
class cl {
  constructor(t = !1) {
    this.detached = t, this._active = !0, this.effects = [], this
    .cleanups = [], this.parent = ke, !t && ke && (this.index = (ke
      .scopes || (ke.scopes = [])).push(this) - 1)
  }
  get active() {
    return this._active
  }
  run(t) {
    if (this._active) {
      const s = ke;
      try {
        return ke = this, t()
      } finally {
        ke = s
      }
    }
  }
  on() {
    ke = this
  }
  off() {
    ke = this.parent
  }
  stop(t) {
    if (this._active) {
      let s, r;
      for (s = 0, r = this.effects.length; s < r; s++) this.effects[s].stop();
      for (s = 0, r = this.cleanups.length; s < r; s++) this.cleanups[s]();
      if (this.scopes)
        for (s = 0, r = this.scopes.length; s < r; s++) this.scopes[s].stop(!
          0);
      if (!this.detached && this.parent && !t) {
        const o = this.parent.scopes.pop();
        o && o !== this && (this.parent.scopes[this.index] = o, o.index = this
          .index)
      }
      this.parent = void 0, this._active = !1
    }
  }
}

function ul(e, t = ke) {
  t && t.active && t.effects.push(e)
}

function dl() {
  return ke
}
let rt;
class Us {
  constructor(t, s, r, o) {
    this.fn = t, this.trigger = s, this.scheduler = r, this.active = !0, this
      .deps = [], this._dirtyLevel = 4, this._trackId = 0, this._runnings = 0,
      this._shouldSchedule = !1, this._depsLength = 0, ul(this, o)
  }
  get dirty() {
    if (this._dirtyLevel === 2 || this._dirtyLevel === 3) {
      this._dirtyLevel = 1, Ge();
      for (let t = 0; t < this._depsLength; t++) {
        const s = this.deps[t];
        if (s.computed && (fl(s.computed), this._dirtyLevel >= 4)) break
      }
      this._dirtyLevel === 1 && (this._dirtyLevel = 0), Je()
    }
    return this._dirtyLevel >= 4
  }
  set dirty(t) {
    this._dirtyLevel = t ? 4 : 0
  }
  run() {
    if (this._dirtyLevel = 0, !this.active) return this.fn();
    let t = ze,
      s = rt;
    try {
      return ze = !0, rt = this, this._runnings++, po(this), this.fn()
    } finally {
      mo(this), this._runnings--, rt = s, ze = t
    }
  }
  stop() {
    this.active && (po(this), mo(this), this.onStop && this.onStop(), this
      .active = !1)
  }
}

function fl(e) {
  return e.value
}

function po(e) {
  e._trackId++, e._depsLength = 0
}

function mo(e) {
  if (e.deps.length > e._depsLength) {
    for (let t = e._depsLength; t < e.deps.length; t++) er(e.deps[t], e);
    e.deps.length = e._depsLength
  }
}

function er(e, t) {
  const s = e.get(t);
  s !== void 0 && t._trackId !== s && (e.delete(t), e.size === 0 && e.cleanup())
}
let ze = !0,
  Es = 0;
const tr = [];

function Ge() {
  tr.push(ze), ze = !1
}

function Je() {
  const e = tr.pop();
  ze = e === void 0 ? !0 : e
}

function Ks() {
  Es++
}

function zs() {
  for (Es--; !Es && js.length;) js.shift()()
}

function sr(e, t, s) {
  if (t.get(e) !== e._trackId) {
    t.set(e, e._trackId);
    const r = e.deps[e._depsLength];
    r !== t ? (r && er(r, e), e.deps[e._depsLength++] = t) : e._depsLength++
  }
}
const js = [];

function or(e, t, s) {
  Ks();
  for (const r of e.keys()) {
    let o;
    r._dirtyLevel < t && (o ?? (o = e.get(r) === r._trackId)) && (r
      ._shouldSchedule || (r._shouldSchedule = r._dirtyLevel === 0), r
      ._dirtyLevel = t), r._shouldSchedule && (o ?? (o = e.get(r) === r
      ._trackId)) && (r.trigger(), (!r._runnings || r.allowRecurse) && r
      ._dirtyLevel !== 2 && (r._shouldSchedule = !1, r.scheduler && js.push(r
        .scheduler)))
  }
  zs()
}
const rr = (e, t) => {
    const s = new Map;
    return s.cleanup = e, s.computed = t, s
  },
  Fs = new WeakMap,
  lt = Symbol(""),
  Ss = Symbol("");

function pe(e, t, s) {
  if (ze && rt) {
    let r = Fs.get(e);
    r || Fs.set(e, r = new Map);
    let o = r.get(s);
    o || r.set(s, o = rr(() => r.delete(s))), sr(rt, o)
  }
}

function Re(e, t, s, r, o, l) {
  const n = Fs.get(e);
  if (!n) return;
  let i = [];
  if (t === "clear") i = [...n.values()];
  else if (s === "length" && F(e)) {
    const u = Number(r);
    n.forEach((f, p) => {
      (p === "length" || !De(p) && p >= u) && i.push(f)
    })
  } else switch (s !== void 0 && i.push(n.get(s)), t) {
    case "add":
      F(e) ? Ns(s) && i.push(n.get("length")) : (i.push(n.get(lt)), ft(e) && i
        .push(n.get(Ss)));
      break;
    case "delete":
      F(e) || (i.push(n.get(lt)), ft(e) && i.push(n.get(Ss)));
      break;
    case "set":
      ft(e) && i.push(n.get(lt));
      break
  }
  Ks();
  for (const u of i) u && or(u, 4);
  zs()
}
const hl = Ds("__proto__,__v_isRef,__isVue"),
  lr = new Set(Object.getOwnPropertyNames(Symbol).filter(e => e !==
    "arguments" && e !== "caller").map(e => Symbol[e]).filter(De)),
  xo = pl();

function pl() {
  const e = {};
  return ["includes", "indexOf", "lastIndexOf"].forEach(t => {
    e[t] = function(...s) {
      const r = U(this);
      for (let l = 0, n = this.length; l < n; l++) pe(r, "get", l + "");
      const o = r[t](...s);
      return o === -1 || o === !1 ? r[t](...s.map(U)) : o
    }
  }), ["push", "pop", "shift", "unshift", "splice"].forEach(t => {
    e[t] = function(...s) {
      Ge(), Ks();
      const r = U(this)[t].apply(this, s);
      return zs(), Je(), r
    }
  }), e
}

function ml(e) {
  De(e) || (e = String(e));
  const t = U(this);
  return pe(t, "has", e), t.hasOwnProperty(e)
}
class ir {
  constructor(t = !1, s = !1) {
    this._isReadonly = t, this._isShallow = s
  }
  get(t, s, r) {
    const o = this._isReadonly,
      l = this._isShallow;
    if (s === "__v_isReactive") return !o;
    if (s === "__v_isReadonly") return o;
    if (s === "__v_isShallow") return l;
    if (s === "__v_raw") return r === (o ? l ? Fl : ur : l ? cr : ar).get(
      t) || Object.getPrototypeOf(t) === Object.getPrototypeOf(r) ? t :
      void 0;
    const n = F(t);
    if (!o) {
      if (n && R(xo, s)) return Reflect.get(xo, s, r);
      if (s === "hasOwnProperty") return ml
    }
    const i = Reflect.get(t, s, r);
    return (De(s) ? lr.has(s) : hl(s)) || (o || pe(t, "get", s), l) ? i : ge(
      i) ? n && Ns(s) ? i : i.value : J(i) ? o ? dr(i) : Gs(i) : i
  }
}
class nr extends ir {
  constructor(t = !1) {
    super(!1, t)
  }
  set(t, s, r, o) {
    let l = t[s];
    if (!this._isShallow) {
      const u = Xt(l);
      if (!Ts(r) && !Xt(r) && (l = U(l), r = U(r)), !F(t) && ge(l) && !ge(r))
        return u ? !1 : (l.value = r, !0)
    }
    const n = F(t) && Ns(s) ? Number(s) < t.length : R(t, s),
      i = Reflect.set(t, s, r, o);
    return t === U(o) && (n ? it(r, l) && Re(t, "set", s, r) : Re(t, "add", s,
      r)), i
  }
  deleteProperty(t, s) {
    const r = R(t, s);
    t[s];
    const o = Reflect.deleteProperty(t, s);
    return o && r && Re(t, "delete", s, void 0), o
  }
  has(t, s) {
    const r = Reflect.has(t, s);
    return (!De(s) || !lr.has(s)) && pe(t, "has", s), r
  }
  ownKeys(t) {
    return pe(t, "iterate", F(t) ? "length" : lt), Reflect.ownKeys(t)
  }
}
class xl extends ir {
  constructor(t = !1) {
    super(!0, t)
  }
  set(t, s) {
    return !0
  }
  deleteProperty(t, s) {
    return !0
  }
}
const gl = new nr,
  bl = new xl,
  _l = new nr(!0);
const Ws = e => e,
  ls = e => Reflect.getPrototypeOf(e);

function Rt(e, t, s = !1, r = !1) {
  e = e.__v_raw;
  const o = U(e),
    l = U(t);
  s || (it(t, l) && pe(o, "get", t), pe(o, "get", l));
  const {
    has: n
  } = ls(o), i = r ? Ws : s ? Xs : Ys;
  if (n.call(o, t)) return i(e.get(t));
  if (n.call(o, l)) return i(e.get(l));
  e !== o && e.get(t)
}

function Dt(e, t = !1) {
  const s = this.__v_raw,
    r = U(s),
    o = U(e);
  return t || (it(e, o) && pe(r, "has", e), pe(r, "has", o)), e === o ? s.has(
    e) : s.has(e) || s.has(o)
}

function Lt(e, t = !1) {
  return e = e.__v_raw, !t && pe(U(e), "iterate", lt), Reflect.get(e, "size", e)
}

function go(e) {
  e = U(e);
  const t = U(this);
  return ls(t).has.call(t, e) || (t.add(e), Re(t, "add", e, e)), this
}

function bo(e, t) {
  t = U(t);
  const s = U(this),
    {
      has: r,
      get: o
    } = ls(s);
  let l = r.call(s, e);
  l || (e = U(e), l = r.call(s, e));
  const n = o.call(s, e);
  return s.set(e, t), l ? it(t, n) && Re(s, "set", e, t) : Re(s, "add", e, t),
    this
}

function _o(e) {
  const t = U(this),
    {
      has: s,
      get: r
    } = ls(t);
  let o = s.call(t, e);
  o || (e = U(e), o = s.call(t, e)), r && r.call(t, e);
  const l = t.delete(e);
  return o && Re(t, "delete", e, void 0), l
}

function wo() {
  const e = U(this),
    t = e.size !== 0,
    s = e.clear();
  return t && Re(e, "clear", void 0, void 0), s
}

function Vt(e, t) {
  return function(r, o) {
    const l = this,
      n = l.__v_raw,
      i = U(n),
      u = t ? Ws : e ? Xs : Ys;
    return !e && pe(i, "iterate", lt), n.forEach((f, p) => r.call(o, u(f), u(
      p), l))
  }
}

function Nt(e, t, s) {
  return function(...r) {
    const o = this.__v_raw,
      l = U(o),
      n = ft(l),
      i = e === "entries" || e === Symbol.iterator && n,
      u = e === "keys" && n,
      f = o[e](...r),
      p = s ? Ws : t ? Xs : Ys;
    return !t && pe(l, "iterate", u ? Ss : lt), {
      next() {
        const {
          value: y,
          done: C
        } = f.next();
        return C ? {
          value: y,
          done: C
        } : {
          value: i ? [p(y[0]), p(y[1])] : p(y),
          done: C
        }
      },
      [Symbol.iterator]() {
        return this
      }
    }
  }
}

function Ne(e) {
  return function(...t) {
    return e === "delete" ? !1 : e === "clear" ? void 0 : this
  }
}

function wl() {
  const e = {
      get(l) {
        return Rt(this, l)
      },
      get size() {
        return Lt(this)
      },
      has: Dt,
      add: go,
      set: bo,
      delete: _o,
      clear: wo,
      forEach: Vt(!1, !1)
    },
    t = {
      get(l) {
        return Rt(this, l, !1, !0)
      },
      get size() {
        return Lt(this)
      },
      has: Dt,
      add: go,
      set: bo,
      delete: _o,
      clear: wo,
      forEach: Vt(!1, !0)
    },
    s = {
      get(l) {
        return Rt(this, l, !0)
      },
      get size() {
        return Lt(this, !0)
      },
      has(l) {
        return Dt.call(this, l, !0)
      },
      add: Ne("add"),
      set: Ne("set"),
      delete: Ne("delete"),
      clear: Ne("clear"),
      forEach: Vt(!0, !1)
    },
    r = {
      get(l) {
        return Rt(this, l, !0, !0)
      },
      get size() {
        return Lt(this, !0)
      },
      has(l) {
        return Dt.call(this, l, !0)
      },
      add: Ne("add"),
      set: Ne("set"),
      delete: Ne("delete"),
      clear: Ne("clear"),
      forEach: Vt(!0, !0)
    };
  return ["keys", "values", "entries", Symbol.iterator].forEach(l => {
    e[l] = Nt(l, !1, !1), s[l] = Nt(l, !0, !1), t[l] = Nt(l, !1, !0), r[l] =
      Nt(l, !0, !0)
  }), [e, s, t, r]
}
const [yl, vl, kl, Al] = wl();

function qs(e, t) {
  const s = t ? e ? Al : kl : e ? vl : yl;
  return (r, o, l) => o === "__v_isReactive" ? !e : o === "__v_isReadonly" ? e :
    o === "__v_raw" ? r : Reflect.get(R(s, o) && o in r ? s : r, o, l)
}
const Cl = {
    get: qs(!1, !1)
  },
  El = {
    get: qs(!1, !0)
  },
  jl = {
    get: qs(!0, !1)
  };
const ar = new WeakMap,
  cr = new WeakMap,
  ur = new WeakMap,
  Fl = new WeakMap;

function Sl(e) {
  switch (e) {
    case "Object":
    case "Array":
      return 1;
    case "Map":
    case "Set":
    case "WeakMap":
    case "WeakSet":
      return 2;
    default:
      return 0
  }
}

function Tl(e) {
  return e.__v_skip || !Object.isExtensible(e) ? 0 : Sl(Qr(e))
}

function Gs(e) {
  return Xt(e) ? e : Js(e, !1, gl, Cl, ar)
}

function Ol(e) {
  return Js(e, !1, _l, El, cr)
}

function dr(e) {
  return Js(e, !0, bl, jl, ur)
}

function Js(e, t, s, r, o) {
  if (!J(e) || e.__v_raw && !(t && e.__v_isReactive)) return e;
  const l = o.get(e);
  if (l) return l;
  const n = Tl(e);
  if (n === 0) return e;
  const i = new Proxy(e, n === 2 ? r : s);
  return o.set(e, i), i
}

function At(e) {
  return Xt(e) ? At(e.__v_raw) : !!(e && e.__v_isReactive)
}

function Xt(e) {
  return !!(e && e.__v_isReadonly)
}

function Ts(e) {
  return !!(e && e.__v_isShallow)
}

function fr(e) {
  return e ? !!e.__v_raw : !1
}

function U(e) {
  const t = e && e.__v_raw;
  return t ? U(t) : e
}

function Pl(e) {
  return Object.isExtensible(e) && Yo(e, "__v_skip", !0), e
}
const Ys = e => J(e) ? Gs(e) : e,
  Xs = e => J(e) ? dr(e) : e;
class hr {
  constructor(t, s, r, o) {
    this.getter = t, this._setter = s, this.dep = void 0, this.__v_isRef = !0,
      this.__v_isReadonly = !1, this.effect = new Us(() => t(this._value),
      () => _s(this, this.effect._dirtyLevel === 2 ? 2 : 3)), this.effect
      .computed = this, this.effect.active = this._cacheable = !o, this
      .__v_isReadonly = r
  }
  get value() {
    const t = U(this);
    return (!t._cacheable || t.effect.dirty) && it(t._value, t._value = t
      .effect.run()) && _s(t, 4), Il(t), t.effect._dirtyLevel >= 2 && _s(t,
      2), t._value
  }
  set value(t) {
    this._setter(t)
  }
  get _dirty() {
    return this.effect.dirty
  }
  set _dirty(t) {
    this.effect.dirty = t
  }
}

function $l(e, t, s = !1) {
  let r, o;
  const l = I(e);
  return l ? (r = e, o = we) : (r = e.get, o = e.set), new hr(r, o, l || !o, s)
}

function Il(e) {
  var t;
  ze && rt && (e = U(e), sr(rt, (t = e.dep) != null ? t : e.dep = rr(() => e
    .dep = void 0, e instanceof hr ? e : void 0)))
}

function _s(e, t = 4, s) {
  e = U(e);
  const r = e.dep;
  r && or(r, t)
}

function ge(e) {
  return !!(e && e.__v_isRef === !0)
}

function Bl(e) {
  return ge(e) ? e.value : e
}
const Ml = {
  get: (e, t, s) => Bl(Reflect.get(e, t, s)),
  set: (e, t, s, r) => {
    const o = e[t];
    return ge(o) && !ge(s) ? (o.value = s, !0) : Reflect.set(e, t, s, r)
  }
};

function pr(e) {
  return At(e) ? e : new Proxy(e, Ml)
}
/**
 * @vue/runtime-core v3.4.27
 * (c) 2018-present Yuxi (Evan) You and Vue contributors
 * @license MIT
 **/
function We(e, t, s, r) {
  try {
    return r ? e(...r) : e()
  } catch (o) {
    is(o, t, s)
  }
}

function Ce(e, t, s, r) {
  if (I(e)) {
    const o = We(e, t, s, r);
    return o && qo(o) && o.catch(l => {
      is(l, t, s)
    }), o
  }
  if (F(e)) {
    const o = [];
    for (let l = 0; l < e.length; l++) o.push(Ce(e[l], t, s, r));
    return o
  }
}

function is(e, t, s, r = !0) {
  const o = t ? t.vnode : null;
  if (t) {
    let l = t.parent;
    const n = t.proxy,
      i = `https://vuejs.org/error-reference/#runtime-${s}`;
    for (; l;) {
      const f = l.ec;
      if (f) {
        for (let p = 0; p < f.length; p++)
          if (f[p](e, n, i) === !1) return
      }
      l = l.parent
    }
    const u = t.appContext.config.errorHandler;
    if (u) {
      Ge(), We(u, null, 10, [e, n, i]), Je();
      return
    }
  }
  Rl(e, s, o, r)
}

function Rl(e, t, s, r = !0) {
  console.error(e)
}
let Ft = !1,
  Os = !1;
const ie = [];
let Pe = 0;
const ht = [];
let He = null,
  st = 0;
const mr = Promise.resolve();
let Zs = null;

function xr(e) {
  const t = Zs || mr;
  return e ? t.then(this ? e.bind(this) : e) : t
}

function Dl(e) {
  let t = Pe + 1,
    s = ie.length;
  for (; t < s;) {
    const r = t + s >>> 1,
      o = ie[r],
      l = St(o);
    l < e || l === e && o.pre ? t = r + 1 : s = r
  }
  return t
}

function Qs(e) {
  (!ie.length || !ie.includes(e, Ft && e.allowRecurse ? Pe + 1 : Pe)) && (e
    .id == null ? ie.push(e) : ie.splice(Dl(e.id), 0, e), gr())
}

function gr() {
  !Ft && !Os && (Os = !0, Zs = mr.then(_r))
}

function Ll(e) {
  const t = ie.indexOf(e);
  t > Pe && ie.splice(t, 1)
}

function Vl(e) {
  F(e) ? ht.push(...e) : (!He || !He.includes(e, e.allowRecurse ? st + 1 :
    st)) && ht.push(e), gr()
}

function yo(e, t, s = Ft ? Pe + 1 : 0) {
  for (; s < ie.length; s++) {
    const r = ie[s];
    if (r && r.pre) {
      if (e && r.id !== e.uid) continue;
      ie.splice(s, 1), s--, r()
    }
  }
}

function br(e) {
  if (ht.length) {
    const t = [...new Set(ht)].sort((s, r) => St(s) - St(r));
    if (ht.length = 0, He) {
      He.push(...t);
      return
    }
    for (He = t, st = 0; st < He.length; st++) He[st]();
    He = null, st = 0
  }
}
const St = e => e.id == null ? 1 / 0 : e.id,
  Nl = (e, t) => {
    const s = St(e) - St(t);
    if (s === 0) {
      if (e.pre && !t.pre) return -1;
      if (t.pre && !e.pre) return 1
    }
    return s
  };

function _r(e) {
  Os = !1, Ft = !0, ie.sort(Nl);
  try {
    for (Pe = 0; Pe < ie.length; Pe++) {
      const t = ie[Pe];
      t && t.active !== !1 && We(t, null, 14)
    }
  } finally {
    Pe = 0, ie.length = 0, br(), Ft = !1, Zs = null, (ie.length || ht.length) &&
      _r()
  }
}

function Hl(e, t, ...s) {
  if (e.isUnmounted) return;
  const r = e.vnode.props || G;
  let o = s;
  const l = t.startsWith("update:"),
    n = l && t.slice(7);
  if (n && n in r) {
    const p = `${n==="modelValue"?"model":n}Modifiers`,
      {
        number: y,
        trim: C
      } = r[p] || G;
    C && (o = s.map($ => Q($) ? $.trim() : $)), y && (o = s.map(Yt))
  }
  let i, u = r[i = gs(t)] || r[i = gs($e(t))];
  !u && l && (u = r[i = gs(ct(t))]), u && Ce(u, e, 6, o);
  const f = r[i + "Once"];
  if (f) {
    if (!e.emitted) e.emitted = {};
    else if (e.emitted[i]) return;
    e.emitted[i] = !0, Ce(f, e, 6, o)
  }
}

function wr(e, t, s = !1) {
  const r = t.emitsCache,
    o = r.get(e);
  if (o !== void 0) return o;
  const l = e.emits;
  let n = {},
    i = !1;
  if (!I(e)) {
    const u = f => {
      const p = wr(f, t, !0);
      p && (i = !0, re(n, p))
    };
    !s && t.mixins.length && t.mixins.forEach(u), e.extends && u(e.extends), e
      .mixins && e.mixins.forEach(u)
  }
  return !l && !i ? (J(e) && r.set(e, null), null) : (F(l) ? l.forEach(u => n[
    u] = null) : re(n, l), J(e) && r.set(e, n), n)
}

function ns(e, t) {
  return !e || !ss(t) ? !1 : (t = t.slice(2).replace(/Once$/, ""), R(e, t[0]
    .toLowerCase() + t.slice(1)) || R(e, ct(t)) || R(e, t))
}
let he = null,
  yr = null;

function Zt(e) {
  const t = he;
  return he = e, yr = e && e.type.__scopeId || null, t
}

function Ul(e, t = he, s) {
  if (!t || e._n) return e;
  const r = (...o) => {
    r._d && Po(-1);
    const l = Zt(t);
    let n;
    try {
      n = e(...o)
    } finally {
      Zt(l), r._d && Po(1)
    }
    return n
  };
  return r._n = !0, r._c = !0, r._d = !0, r
}

function ws(e) {
  const {
    type: t,
    vnode: s,
    proxy: r,
    withProxy: o,
    propsOptions: [l],
    slots: n,
    attrs: i,
    emit: u,
    render: f,
    renderCache: p,
    props: y,
    data: C,
    setupState: $,
    ctx: K,
    inheritAttrs: V
  } = e, me = Zt(e);
  let ee, le;
  try {
    if (s.shapeFlag & 4) {
      const te = o || r,
        be = te;
      ee = Oe(f.call(be, te, p, y, $, C, K)), le = i
    } else {
      const te = t;
      ee = Oe(te.length > 1 ? te(y, {
        attrs: i,
        slots: n,
        emit: u
      }) : te(y, null)), le = t.props ? i : Kl(i)
    }
  } catch (te) {
    jt.length = 0, is(te, e, 1), ee = H(at)
  }
  let W = ee;
  if (le && V !== !1) {
    const te = Object.keys(le),
      {
        shapeFlag: be
      } = W;
    te.length && be & 7 && (l && te.some(Ls) && (le = zl(le, l)), W = pt(W, le,
      !1, !0))
  }
  return s.dirs && (W = pt(W, null, !1, !0), W.dirs = W.dirs ? W.dirs.concat(s
      .dirs) : s.dirs), s.transition && (W.transition = s.transition), ee = W,
    Zt(me), ee
}
const Kl = e => {
    let t;
    for (const s in e)(s === "class" || s === "style" || ss(s)) && ((t || (
      t = {}))[s] = e[s]);
    return t
  },
  zl = (e, t) => {
    const s = {};
    for (const r in e)(!Ls(r) || !(r.slice(9) in t)) && (s[r] = e[r]);
    return s
  };

function Wl(e, t, s) {
  const {
    props: r,
    children: o,
    component: l
  } = e, {
    props: n,
    children: i,
    patchFlag: u
  } = t, f = l.emitsOptions;
  if (t.dirs || t.transition) return !0;
  if (s && u >= 0) {
    if (u & 1024) return !0;
    if (u & 16) return r ? vo(r, n, f) : !!n;
    if (u & 8) {
      const p = t.dynamicProps;
      for (let y = 0; y < p.length; y++) {
        const C = p[y];
        if (n[C] !== r[C] && !ns(f, C)) return !0
      }
    }
  } else return (o || i) && (!i || !i.$stable) ? !0 : r === n ? !1 : r ? n ? vo(
    r, n, f) : !0 : !!n;
  return !1
}

function vo(e, t, s) {
  const r = Object.keys(t);
  if (r.length !== Object.keys(e).length) return !0;
  for (let o = 0; o < r.length; o++) {
    const l = r[o];
    if (t[l] !== e[l] && !ns(s, l)) return !0
  }
  return !1
}

function ql({
  vnode: e,
  parent: t
}, s) {
  for (; t;) {
    const r = t.subTree;
    if (r.suspense && r.suspense.activeBranch === e && (r.el = e.el), r === e)(
      e = t.vnode).el = s, t = t.parent;
    else break
  }
}
const vr = "components";

function oe(e, t) {
  return Jl(vr, e, !0, t) || e
}
const Gl = Symbol.for("v-ndc");

function Jl(e, t, s = !0, r = !1) {
  const o = he || ne;
  if (o) {
    const l = o.type;
    if (e === vr) {
      const i = zi(l, !1);
      if (i && (i === t || i === $e(t) || i === rs($e(t)))) return l
    }
    const n = ko(o[e] || l[e], t) || ko(o.appContext[e], t);
    return !n && r ? l : n
  }
}

function ko(e, t) {
  return e && (e[t] || e[$e(t)] || e[rs($e(t))])
}
const Yl = e => e.__isSuspense;

function Xl(e, t) {
  t && t.pendingBranch ? F(e) ? t.effects.push(...e) : t.effects.push(e) : Vl(e)
}
const Zl = Symbol.for("v-scx"),
  Ql = () => Wt(Zl),
  Ht = {};

function ys(e, t, s) {
  return kr(e, t, s)
}

function kr(e, t, {
  immediate: s,
  deep: r,
  flush: o,
  once: l,
  onTrack: n,
  onTrigger: i
} = G) {
  if (t && l) {
    const L = t;
    t = (...Ie) => {
      L(...Ie), be()
    }
  }
  const u = ne,
    f = L => r === !0 ? L : ot(L, r === !1 ? 1 : void 0);
  let p, y = !1,
    C = !1;
  if (ge(e) ? (p = () => e.value, y = Ts(e)) : At(e) ? (p = () => f(e), y = !
    0) : F(e) ? (C = !0, y = e.some(L => At(L) || Ts(L)), p = () => e.map(L => {
      if (ge(L)) return L.value;
      if (At(L)) return f(L);
      if (I(L)) return We(L, u, 2)
    })) : I(e) ? t ? p = () => We(e, u, 2) : p = () => ($ && $(), Ce(e, u, 3, [
      K])) : p = we, t && r) {
    const L = p;
    p = () => ot(L())
  }
  let $, K = L => {
      $ = W.onStop = () => {
        We(L, u, 4), $ = W.onStop = void 0
      }
    },
    V;
  if (ds)
    if (K = we, t ? s && Ce(t, u, 3, [p(), C ? [] : void 0, K]) : p(), o ===
      "sync") {
      const L = Ql();
      V = L.__watcherHandles || (L.__watcherHandles = [])
    } else return we;
  let me = C ? new Array(e.length).fill(Ht) : Ht;
  const ee = () => {
    if (!(!W.active || !W.dirty))
      if (t) {
        const L = W.run();
        (r || y || (C ? L.some((Ie, je) => it(Ie, me[je])) : it(L, me))) && (
          $ && $(), Ce(t, u, 3, [L, me === Ht ? void 0 : C && me[0] === Ht ?
          [] : me, K]), me = L)
      } else W.run()
  };
  ee.allowRecurse = !!t;
  let le;
  o === "sync" ? le = ee : o === "post" ? le = () => de(ee, u && u.suspense) : (
    ee.pre = !0, u && (ee.id = u.uid), le = () => Qs(ee));
  const W = new Us(p, we, le),
    te = dl(),
    be = () => {
      W.stop(), te && Vs(te.effects, W)
    };
  return t ? s ? ee() : me = W.run() : o === "post" ? de(W.run.bind(W), u && u
    .suspense) : W.run(), V && V.push(be), be
}

function ei(e, t, s) {
  const r = this.proxy,
    o = Q(e) ? e.includes(".") ? Ar(r, e) : () => r[e] : e.bind(r, r);
  let l;
  I(t) ? l = t : (l = t.handler, s = t);
  const n = Pt(this),
    i = kr(o, l.bind(r), s);
  return n(), i
}

function Ar(e, t) {
  const s = t.split(".");
  return () => {
    let r = e;
    for (let o = 0; o < s.length && r; o++) r = r[s[o]];
    return r
  }
}

function ot(e, t = 1 / 0, s) {
  if (t <= 0 || !J(e) || e.__v_skip || (s = s || new Set, s.has(e))) return e;
  if (s.add(e), t--, ge(e)) ot(e.value, t, s);
  else if (F(e))
    for (let r = 0; r < e.length; r++) ot(e[r], t, s);
  else if (xt(e) || ft(e)) e.forEach(r => {
    ot(r, t, s)
  });
  else if (Jo(e))
    for (const r in e) ot(e[r], t, s);
  return e
}

function S(e, t) {
  if (he === null) return e;
  const s = fs(he) || he.proxy,
    r = e.dirs || (e.dirs = []);
  for (let o = 0; o < t.length; o++) {
    let [l, n, i, u = G] = t[o];
    l && (I(l) && (l = {
      mounted: l,
      updated: l
    }), l.deep && ot(n), r.push({
      dir: l,
      instance: s,
      value: n,
      oldValue: void 0,
      arg: i,
      modifiers: u
    }))
  }
  return e
}

function Qe(e, t, s, r) {
  const o = e.dirs,
    l = t && t.dirs;
  for (let n = 0; n < o.length; n++) {
    const i = o[n];
    l && (i.oldValue = l[n].value);
    let u = i.dir[r];
    u && (Ge(), Ce(u, s, 8, [e.el, i, e, t]), Je())
  }
}
const zt = e => !!e.type.__asyncLoader,
  Cr = e => e.type.__isKeepAlive;

function ti(e, t) {
  Er(e, "a", t)
}

function si(e, t) {
  Er(e, "da", t)
}

function Er(e, t, s = ne) {
  const r = e.__wdc || (e.__wdc = () => {
    let o = s;
    for (; o;) {
      if (o.isDeactivated) return;
      o = o.parent
    }
    return e()
  });
  if (as(t, r, s), s) {
    let o = s.parent;
    for (; o && o.parent;) Cr(o.parent.vnode) && oi(r, t, s, o), o = o.parent
  }
}

function oi(e, t, s, r) {
  const o = as(t, e, r, !0);
  jr(() => {
    Vs(r[t], o)
  }, s)
}

function as(e, t, s = ne, r = !1) {
  if (s) {
    const o = s[e] || (s[e] = []),
      l = t.__weh || (t.__weh = (...n) => {
        if (s.isUnmounted) return;
        Ge();
        const i = Pt(s),
          u = Ce(t, s, e, n);
        return i(), Je(), u
      });
    return r ? o.unshift(l) : o.push(l), l
  }
}
const Ve = e => (t, s = ne) => (!ds || e === "sp") && as(e, (...r) => t(...r),
    s),
  ri = Ve("bm"),
  li = Ve("m"),
  ii = Ve("bu"),
  ni = Ve("u"),
  ai = Ve("bum"),
  jr = Ve("um"),
  ci = Ve("sp"),
  ui = Ve("rtg"),
  di = Ve("rtc");

function fi(e, t = ne) {
  as("ec", e, t)
}

function Ee(e, t, s, r) {
  let o;
  const l = s;
  if (F(e) || Q(e)) {
    o = new Array(e.length);
    for (let n = 0, i = e.length; n < i; n++) o[n] = t(e[n], n, void 0, l)
  } else if (typeof e == "number") {
    o = new Array(e);
    for (let n = 0; n < e; n++) o[n] = t(n + 1, n, void 0, l)
  } else if (J(e))
    if (e[Symbol.iterator]) o = Array.from(e, (n, i) => t(n, i, void 0, l));
    else {
      const n = Object.keys(e);
      o = new Array(n.length);
      for (let i = 0, u = n.length; i < u; i++) {
        const f = n[i];
        o[i] = t(e[f], f, i, l)
      }
    }
  else o = [];
  return o
}
const Ps = e => e ? Hr(e) ? fs(e) || e.proxy : Ps(e.parent) : null,
  Ct = re(Object.create(null), {
    $: e => e,
    $el: e => e.vnode.el,
    $data: e => e.data,
    $props: e => e.props,
    $attrs: e => e.attrs,
    $slots: e => e.slots,
    $refs: e => e.refs,
    $parent: e => Ps(e.parent),
    $root: e => Ps(e.root),
    $emit: e => e.emit,
    $options: e => eo(e),
    $forceUpdate: e => e.f || (e.f = () => {
      e.effect.dirty = !0, Qs(e.update)
    }),
    $nextTick: e => e.n || (e.n = xr.bind(e.proxy)),
    $watch: e => ei.bind(e)
  }),
  vs = (e, t) => e !== G && !e.__isScriptSetup && R(e, t),
  hi = {
    get({
      _: e
    }, t) {
      if (t === "__v_skip") return !0;
      const {
        ctx: s,
        setupState: r,
        data: o,
        props: l,
        accessCache: n,
        type: i,
        appContext: u
      } = e;
      let f;
      if (t[0] !== "$") {
        const $ = n[t];
        if ($ !== void 0) switch ($) {
          case 1:
            return r[t];
          case 2:
            return o[t];
          case 4:
            return s[t];
          case 3:
            return l[t]
        } else {
          if (vs(r, t)) return n[t] = 1, r[t];
          if (o !== G && R(o, t)) return n[t] = 2, o[t];
          if ((f = e.propsOptions[0]) && R(f, t)) return n[t] = 3, l[t];
          if (s !== G && R(s, t)) return n[t] = 4, s[t];
          $s && (n[t] = 0)
        }
      }
      const p = Ct[t];
      let y, C;
      if (p) return t === "$attrs" && pe(e.attrs, "get", ""), p(e);
      if ((y = i.__cssModules) && (y = y[t])) return y;
      if (s !== G && R(s, t)) return n[t] = 4, s[t];
      if (C = u.config.globalProperties, R(C, t)) return C[t]
    },
    set({
      _: e
    }, t, s) {
      const {
        data: r,
        setupState: o,
        ctx: l
      } = e;
      return vs(o, t) ? (o[t] = s, !0) : r !== G && R(r, t) ? (r[t] = s, !0) :
        R(e.props, t) || t[0] === "$" && t.slice(1) in e ? !1 : (l[t] = s, !0)
    },
    has({
      _: {
        data: e,
        setupState: t,
        accessCache: s,
        ctx: r,
        appContext: o,
        propsOptions: l
      }
    }, n) {
      let i;
      return !!s[n] || e !== G && R(e, n) || vs(t, n) || (i = l[0]) && R(i,
        n) || R(r, n) || R(Ct, n) || R(o.config.globalProperties, n)
    },
    defineProperty(e, t, s) {
      return s.get != null ? e._.accessCache[t] = 0 : R(s, "value") && this.set(
        e, t, s.value, null), Reflect.defineProperty(e, t, s)
    }
  };

function Ao(e) {
  return F(e) ? e.reduce((t, s) => (t[s] = null, t), {}) : e
}
let $s = !0;

function pi(e) {
  const t = eo(e),
    s = e.proxy,
    r = e.ctx;
  $s = !1, t.beforeCreate && Co(t.beforeCreate, e, "bc");
  const {
    data: o,
    computed: l,
    methods: n,
    watch: i,
    provide: u,
    inject: f,
    created: p,
    beforeMount: y,
    mounted: C,
    beforeUpdate: $,
    updated: K,
    activated: V,
    deactivated: me,
    beforeDestroy: ee,
    beforeUnmount: le,
    destroyed: W,
    unmounted: te,
    render: be,
    renderTracked: L,
    renderTriggered: Ie,
    errorCaptured: je,
    serverPrefetch: ps,
    expose: Ye,
    inheritAttrs: gt,
    components: $t,
    directives: It,
    filters: ms
  } = t;
  if (f && mi(f, r, null), n)
    for (const X in n) {
      const q = n[X];
      I(q) && (r[X] = q.bind(s))
    }
  if (o) {
    const X = o.call(s, s);
    J(X) && (e.data = Gs(X))
  }
  if ($s = !0, l)
    for (const X in l) {
      const q = l[X],
        Xe = I(q) ? q.bind(s, s) : I(q.get) ? q.get.bind(s, s) : we,
        Bt = !I(q) && I(q.set) ? q.set.bind(s) : we,
        Ze = qi({
          get: Xe,
          set: Bt
        });
      Object.defineProperty(r, X, {
        enumerable: !0,
        configurable: !0,
        get: () => Ze.value,
        set: Fe => Ze.value = Fe
      })
    }
  if (i)
    for (const X in i) Fr(i[X], r, s, X);
  if (u) {
    const X = I(u) ? u.call(s) : u;
    Reflect.ownKeys(X).forEach(q => {
      yi(q, X[q])
    })
  }
  p && Co(p, e, "c");

  function ae(X, q) {
    F(q) ? q.forEach(Xe => X(Xe.bind(s))) : q && X(q.bind(s))
  }
  if (ae(ri, y), ae(li, C), ae(ii, $), ae(ni, K), ae(ti, V), ae(si, me), ae(fi,
      je), ae(di, L), ae(ui, Ie), ae(ai, le), ae(jr, te), ae(ci, ps), F(Ye))
    if (Ye.length) {
      const X = e.exposed || (e.exposed = {});
      Ye.forEach(q => {
        Object.defineProperty(X, q, {
          get: () => s[q],
          set: Xe => s[q] = Xe
        })
      })
    } else e.exposed || (e.exposed = {});
  be && e.render === we && (e.render = be), gt != null && (e.inheritAttrs = gt),
    $t && (e.components = $t), It && (e.directives = It)
}

function mi(e, t, s = we) {
  F(e) && (e = Is(e));
  for (const r in e) {
    const o = e[r];
    let l;
    J(o) ? "default" in o ? l = Wt(o.from || r, o.default, !0) : l = Wt(o
      .from || r) : l = Wt(o), ge(l) ? Object.defineProperty(t, r, {
      enumerable: !0,
      configurable: !0,
      get: () => l.value,
      set: n => l.value = n
    }) : t[r] = l
  }
}

function Co(e, t, s) {
  Ce(F(e) ? e.map(r => r.bind(t.proxy)) : e.bind(t.proxy), t, s)
}

function Fr(e, t, s, r) {
  const o = r.includes(".") ? Ar(s, r) : () => s[r];
  if (Q(e)) {
    const l = t[e];
    I(l) && ys(o, l)
  } else if (I(e)) ys(o, e.bind(s));
  else if (J(e))
    if (F(e)) e.forEach(l => Fr(l, t, s, r));
    else {
      const l = I(e.handler) ? e.handler.bind(s) : t[e.handler];
      I(l) && ys(o, l, e)
    }
}

function eo(e) {
  const t = e.type,
    {
      mixins: s,
      extends: r
    } = t,
    {
      mixins: o,
      optionsCache: l,
      config: {
        optionMergeStrategies: n
      }
    } = e.appContext,
    i = l.get(t);
  let u;
  return i ? u = i : !o.length && !s && !r ? u = t : (u = {}, o.length && o
    .forEach(f => Qt(u, f, n, !0)), Qt(u, t, n)), J(t) && l.set(t, u), u
}

function Qt(e, t, s, r = !1) {
  const {
    mixins: o,
    extends: l
  } = t;
  l && Qt(e, l, s, !0), o && o.forEach(n => Qt(e, n, s, !0));
  for (const n in t)
    if (!(r && n === "expose")) {
      const i = xi[n] || s && s[n];
      e[n] = i ? i(e[n], t[n]) : t[n]
    } return e
}
const xi = {
  data: Eo,
  props: jo,
  emits: jo,
  methods: vt,
  computed: vt,
  beforeCreate: ce,
  created: ce,
  beforeMount: ce,
  mounted: ce,
  beforeUpdate: ce,
  updated: ce,
  beforeDestroy: ce,
  beforeUnmount: ce,
  destroyed: ce,
  unmounted: ce,
  activated: ce,
  deactivated: ce,
  errorCaptured: ce,
  serverPrefetch: ce,
  components: vt,
  directives: vt,
  watch: bi,
  provide: Eo,
  inject: gi
};

function Eo(e, t) {
  return t ? e ? function() {
    return re(I(e) ? e.call(this, this) : e, I(t) ? t.call(this, this) : t)
  } : t : e
}

function gi(e, t) {
  return vt(Is(e), Is(t))
}

function Is(e) {
  if (F(e)) {
    const t = {};
    for (let s = 0; s < e.length; s++) t[e[s]] = e[s];
    return t
  }
  return e
}

function ce(e, t) {
  return e ? [...new Set([].concat(e, t))] : t
}

function vt(e, t) {
  return e ? re(Object.create(null), e, t) : t
}

function jo(e, t) {
  return e ? F(e) && F(t) ? [...new Set([...e, ...t])] : re(Object.create(null),
    Ao(e), Ao(t ?? {})) : t
}

function bi(e, t) {
  if (!e) return t;
  if (!t) return e;
  const s = re(Object.create(null), e);
  for (const r in t) s[r] = ce(e[r], t[r]);
  return s
}

function Sr() {
  return {
    app: null,
    config: {
      isNativeTag: Xr,
      performance: !1,
      globalProperties: {},
      optionMergeStrategies: {},
      errorHandler: void 0,
      warnHandler: void 0,
      compilerOptions: {}
    },
    mixins: [],
    components: {},
    directives: {},
    provides: Object.create(null),
    optionsCache: new WeakMap,
    propsCache: new WeakMap,
    emitsCache: new WeakMap
  }
}
let _i = 0;

function wi(e, t) {
  return function(r, o = null) {
    I(r) || (r = re({}, r)), o != null && !J(o) && (o = null);
    const l = Sr(),
      n = new WeakSet;
    let i = !1;
    const u = l.app = {
      _uid: _i++,
      _component: r,
      _props: o,
      _container: null,
      _context: l,
      _instance: null,
      version: Gi,
      get config() {
        return l.config
      },
      set config(f) {},
      use(f, ...p) {
        return n.has(f) || (f && I(f.install) ? (n.add(f), f.install(u, ...
          p)) : I(f) && (n.add(f), f(u, ...p))), u
      },
      mixin(f) {
        return l.mixins.includes(f) || l.mixins.push(f), u
      },
      component(f, p) {
        return p ? (l.components[f] = p, u) : l.components[f]
      },
      directive(f, p) {
        return p ? (l.directives[f] = p, u) : l.directives[f]
      },
      mount(f, p, y) {
        if (!i) {
          const C = H(r, o);
          return C.appContext = l, y === !0 ? y = "svg" : y === !1 && (y =
              void 0), p && t ? t(C, f) : e(C, f, y), i = !0, u._container =
            f, f.__vue_app__ = u, fs(C.component) || C.component.proxy
        }
      },
      unmount() {
        i && (e(null, u._container), delete u._container.__vue_app__)
      },
      provide(f, p) {
        return l.provides[f] = p, u
      },
      runWithContext(f) {
        const p = Et;
        Et = u;
        try {
          return f()
        } finally {
          Et = p
        }
      }
    };
    return u
  }
}
let Et = null;

function yi(e, t) {
  if (ne) {
    let s = ne.provides;
    const r = ne.parent && ne.parent.provides;
    r === s && (s = ne.provides = Object.create(r)), s[e] = t
  }
}

function Wt(e, t, s = !1) {
  const r = ne || he;
  if (r || Et) {
    const o = r ? r.parent == null ? r.vnode.appContext && r.vnode.appContext
      .provides : r.parent.provides : Et._context.provides;
    if (o && e in o) return o[e];
    if (arguments.length > 1) return s && I(t) ? t.call(r && r.proxy) : t
  }
}
const Tr = {},
  Or = () => Object.create(Tr),
  Pr = e => Object.getPrototypeOf(e) === Tr;

function vi(e, t, s, r = !1) {
  const o = {},
    l = Or();
  e.propsDefaults = Object.create(null), $r(e, t, o, l);
  for (const n in e.propsOptions[0]) n in o || (o[n] = void 0);
  s ? e.props = r ? o : Ol(o) : e.type.props ? e.props = o : e.props = l, e
    .attrs = l
}

function ki(e, t, s, r) {
  const {
    props: o,
    attrs: l,
    vnode: {
      patchFlag: n
    }
  } = e, i = U(o), [u] = e.propsOptions;
  let f = !1;
  if ((r || n > 0) && !(n & 16)) {
    if (n & 8) {
      const p = e.vnode.dynamicProps;
      for (let y = 0; y < p.length; y++) {
        let C = p[y];
        if (ns(e.emitsOptions, C)) continue;
        const $ = t[C];
        if (u)
          if (R(l, C)) $ !== l[C] && (l[C] = $, f = !0);
          else {
            const K = $e(C);
            o[K] = Bs(u, i, K, $, e, !1)
          }
        else $ !== l[C] && (l[C] = $, f = !0)
      }
    }
  } else {
    $r(e, t, o, l) && (f = !0);
    let p;
    for (const y in i)(!t || !R(t, y) && ((p = ct(y)) === y || !R(t, p))) && (
      u ? s && (s[y] !== void 0 || s[p] !== void 0) && (o[y] = Bs(u, i, y,
        void 0, e, !0)) : delete o[y]);
    if (l !== i)
      for (const y in l)(!t || !R(t, y)) && (delete l[y], f = !0)
  }
  f && Re(e.attrs, "set", "")
}

function $r(e, t, s, r) {
  const [o, l] = e.propsOptions;
  let n = !1,
    i;
  if (t)
    for (let u in t) {
      if (kt(u)) continue;
      const f = t[u];
      let p;
      o && R(o, p = $e(u)) ? !l || !l.includes(p) ? s[p] = f : (i || (i = {}))[
        p] = f : ns(e.emitsOptions, u) || (!(u in r) || f !== r[u]) && (r[u] =
        f, n = !0)
    }
  if (l) {
    const u = U(s),
      f = i || G;
    for (let p = 0; p < l.length; p++) {
      const y = l[p];
      s[y] = Bs(o, u, y, f[y], e, !R(f, y))
    }
  }
  return n
}

function Bs(e, t, s, r, o, l) {
  const n = e[s];
  if (n != null) {
    const i = R(n, "default");
    if (i && r === void 0) {
      const u = n.default;
      if (n.type !== Function && !n.skipFactory && I(u)) {
        const {
          propsDefaults: f
        } = o;
        if (s in f) r = f[s];
        else {
          const p = Pt(o);
          r = f[s] = u.call(null, t), p()
        }
      } else r = u
    }
    n[0] && (l && !i ? r = !1 : n[1] && (r === "" || r === ct(s)) && (r = !0))
  }
  return r
}

function Ir(e, t, s = !1) {
  const r = t.propsCache,
    o = r.get(e);
  if (o) return o;
  const l = e.props,
    n = {},
    i = [];
  let u = !1;
  if (!I(e)) {
    const p = y => {
      u = !0;
      const [C, $] = Ir(y, t, !0);
      re(n, C), $ && i.push(...$)
    };
    !s && t.mixins.length && t.mixins.forEach(p), e.extends && p(e.extends), e
      .mixins && e.mixins.forEach(p)
  }
  if (!l && !u) return J(e) && r.set(e, dt), dt;
  if (F(l))
    for (let p = 0; p < l.length; p++) {
      const y = $e(l[p]);
      Fo(y) && (n[y] = G)
    } else if (l)
      for (const p in l) {
        const y = $e(p);
        if (Fo(y)) {
          const C = l[p],
            $ = n[y] = F(C) || I(C) ? {
              type: C
            } : re({}, C);
          if ($) {
            const K = Oo(Boolean, $.type),
              V = Oo(String, $.type);
            $[0] = K > -1, $[1] = V < 0 || K < V, (K > -1 || R($, "default")) &&
              i.push(y)
          }
        }
      }
  const f = [n, i];
  return J(e) && r.set(e, f), f
}

function Fo(e) {
  return e[0] !== "$" && !kt(e)
}

function So(e) {
  return e === null ? "null" : typeof e == "function" ? e.name || "" :
    typeof e == "object" && e.constructor && e.constructor.name || ""
}

function To(e, t) {
  return So(e) === So(t)
}

function Oo(e, t) {
  return F(t) ? t.findIndex(s => To(s, e)) : I(t) && To(t, e) ? 0 : -1
}
const Br = e => e[0] === "_" || e === "$stable",
  to = e => F(e) ? e.map(Oe) : [Oe(e)],
  Ai = (e, t, s) => {
    if (t._n) return t;
    const r = Ul((...o) => to(t(...o)), s);
    return r._c = !1, r
  },
  Mr = (e, t, s) => {
    const r = e._ctx;
    for (const o in e) {
      if (Br(o)) continue;
      const l = e[o];
      if (I(l)) t[o] = Ai(o, l, r);
      else if (l != null) {
        const n = to(l);
        t[o] = () => n
      }
    }
  },
  Rr = (e, t) => {
    const s = to(t);
    e.slots.default = () => s
  },
  Ci = (e, t) => {
    const s = e.slots = Or();
    if (e.vnode.shapeFlag & 32) {
      const r = t._;
      r ? (re(s, t), Yo(s, "_", r, !0)) : Mr(t, s)
    } else t && Rr(e, t)
  },
  Ei = (e, t, s) => {
    const {
      vnode: r,
      slots: o
    } = e;
    let l = !0,
      n = G;
    if (r.shapeFlag & 32) {
      const i = t._;
      i ? s && i === 1 ? l = !1 : (re(o, t), !s && i === 1 && delete o._) : (
        l = !t.$stable, Mr(t, o)), n = t
    } else t && (Rr(e, t), n = {
      default: 1
    });
    if (l)
      for (const i in o) !Br(i) && n[i] == null && delete o[i]
  };

function Ms(e, t, s, r, o = !1) {
  if (F(e)) {
    e.forEach((C, $) => Ms(C, t && (F(t) ? t[$] : t), s, r, o));
    return
  }
  if (zt(r) && !o) return;
  const l = r.shapeFlag & 4 ? fs(r.component) || r.component.proxy : r.el,
    n = o ? null : l,
    {
      i,
      r: u
    } = e,
    f = t && t.r,
    p = i.refs === G ? i.refs = {} : i.refs,
    y = i.setupState;
  if (f != null && f !== u && (Q(f) ? (p[f] = null, R(y, f) && (y[f] = null)) :
      ge(f) && (f.value = null)), I(u)) We(u, i, 12, [n, p]);
  else {
    const C = Q(u),
      $ = ge(u);
    if (C || $) {
      const K = () => {
        if (e.f) {
          const V = C ? R(y, u) ? y[u] : p[u] : u.value;
          o ? F(V) && Vs(V, l) : F(V) ? V.includes(l) || V.push(l) : C ? (p[
            u] = [l], R(y, u) && (y[u] = p[u])) : (u.value = [l], e.k && (p[
            e.k] = u.value))
        } else C ? (p[u] = n, R(y, u) && (y[u] = n)) : $ && (u.value = n, e
          .k && (p[e.k] = n))
      };
      n ? (K.id = -1, de(K, s)) : K()
    }
  }
}
const de = Xl;

function ji(e) {
  return Fi(e)
}

function Fi(e, t) {
  const s = Xo();
  s.__VUE__ = !0;
  const {
    insert: r,
    remove: o,
    patchProp: l,
    createElement: n,
    createText: i,
    createComment: u,
    setText: f,
    setElementText: p,
    parentNode: y,
    nextSibling: C,
    setScopeId: $ = we,
    insertStaticContent: K
  } = e, V = (c, d, h, m = null, x = null, _ = null, v = void 0, b = null, w = !
      !d.dynamicChildren) => {
      if (c === d) return;
      c && !wt(c, d) && (m = Mt(c), Fe(c, x, _, !0), c = null), d.patchFlag ===
        -2 && (w = !1, d.dynamicChildren = null);
      const {
        type: g,
        ref: A,
        shapeFlag: j
      } = d;
      switch (g) {
        case cs:
          me(c, d, h, m);
          break;
        case at:
          ee(c, d, h, m);
          break;
        case qt:
          c == null && le(d, h, m, v);
          break;
        case z:
          $t(c, d, h, m, x, _, v, b, w);
          break;
        default:
          j & 1 ? be(c, d, h, m, x, _, v, b, w) : j & 6 ? It(c, d, h, m, x, _,
            v, b, w) : (j & 64 || j & 128) && g.process(c, d, h, m, x, _, v,
            b, w, bt)
      }
      A != null && x && Ms(A, c && c.ref, _, d || c, !d)
    }, me = (c, d, h, m) => {
      if (c == null) r(d.el = i(d.children), h, m);
      else {
        const x = d.el = c.el;
        d.children !== c.children && f(x, d.children)
      }
    }, ee = (c, d, h, m) => {
      c == null ? r(d.el = u(d.children || ""), h, m) : d.el = c.el
    }, le = (c, d, h, m) => {
      [c.el, c.anchor] = K(c.children, d, h, m, c.el, c.anchor)
    }, W = ({
      el: c,
      anchor: d
    }, h, m) => {
      let x;
      for (; c && c !== d;) x = C(c), r(c, h, m), c = x;
      r(d, h, m)
    }, te = ({
      el: c,
      anchor: d
    }) => {
      let h;
      for (; c && c !== d;) h = C(c), o(c), c = h;
      o(d)
    }, be = (c, d, h, m, x, _, v, b, w) => {
      d.type === "svg" ? v = "svg" : d.type === "math" && (v = "mathml"), c ==
        null ? L(d, h, m, x, _, v, b, w) : ps(c, d, x, _, v, b, w)
    }, L = (c, d, h, m, x, _, v, b) => {
      let w, g;
      const {
        props: A,
        shapeFlag: j,
        transition: E,
        dirs: O
      } = c;
      if (w = c.el = n(c.type, _, A && A.is, A), j & 8 ? p(w, c.children) : j &
        16 && je(c.children, w, null, m, x, ks(c, _), v, b), O && Qe(c, null, m,
          "created"), Ie(w, c, c.scopeId, v, m), A) {
        for (const N in A) N !== "value" && !kt(N) && l(w, N, null, A[N], _, c
          .children, m, x, Be);
        "value" in A && l(w, "value", null, A.value, _), (g = A
          .onVnodeBeforeMount) && Te(g, m, c)
      }
      O && Qe(c, null, m, "beforeMount");
      const B = Si(x, E);
      B && E.beforeEnter(w), r(w, d, h), ((g = A && A.onVnodeMounted) || B ||
        O) && de(() => {
          g && Te(g, m, c), B && E.enter(w), O && Qe(c, null, m, "mounted")
        }, x)
    }, Ie = (c, d, h, m, x) => {
      if (h && $(c, h), m)
        for (let _ = 0; _ < m.length; _++) $(c, m[_]);
      if (x) {
        let _ = x.subTree;
        if (d === _) {
          const v = x.vnode;
          Ie(c, v, v.scopeId, v.slotScopeIds, x.parent)
        }
      }
    }, je = (c, d, h, m, x, _, v, b, w = 0) => {
      for (let g = w; g < c.length; g++) {
        const A = c[g] = b ? Ue(c[g]) : Oe(c[g]);
        V(null, A, d, h, m, x, _, v, b)
      }
    }, ps = (c, d, h, m, x, _, v) => {
      const b = d.el = c.el;
      let {
        patchFlag: w,
        dynamicChildren: g,
        dirs: A
      } = d;
      w |= c.patchFlag & 16;
      const j = c.props || G,
        E = d.props || G;
      let O;
      if (h && et(h, !1), (O = E.onVnodeBeforeUpdate) && Te(O, h, d, c), A &&
        Qe(d, c, h, "beforeUpdate"), h && et(h, !0), g ? Ye(c.dynamicChildren,
          g, b, h, m, ks(d, x), _) : v || q(c, d, b, null, h, m, ks(d, x), _, !
          1), w > 0) {
        if (w & 16) gt(b, d, j, E, h, m, x);
        else if (w & 2 && j.class !== E.class && l(b, "class", null, E.class,
          x), w & 4 && l(b, "style", j.style, E.style, x), w & 8) {
          const B = d.dynamicProps;
          for (let N = 0; N < B.length; N++) {
            const Y = B[N],
              se = j[Y],
              ve = E[Y];
            (ve !== se || Y === "value") && l(b, Y, se, ve, x, c.children, h, m,
              Be)
          }
        }
        w & 1 && c.children !== d.children && p(b, d.children)
      } else !v && g == null && gt(b, d, j, E, h, m, x);
      ((O = E.onVnodeUpdated) || A) && de(() => {
        O && Te(O, h, d, c), A && Qe(d, c, h, "updated")
      }, m)
    }, Ye = (c, d, h, m, x, _, v) => {
      for (let b = 0; b < d.length; b++) {
        const w = c[b],
          g = d[b],
          A = w.el && (w.type === z || !wt(w, g) || w.shapeFlag & 70) ? y(w
          .el) : h;
        V(w, g, A, null, m, x, _, v, !0)
      }
    }, gt = (c, d, h, m, x, _, v) => {
      if (h !== m) {
        if (h !== G)
          for (const b in h) !kt(b) && !(b in m) && l(c, b, h[b], null, v, d
            .children, x, _, Be);
        for (const b in m) {
          if (kt(b)) continue;
          const w = m[b],
            g = h[b];
          w !== g && b !== "value" && l(c, b, g, w, v, d.children, x, _, Be)
        }
        "value" in m && l(c, "value", h.value, m.value, v)
      }
    }, $t = (c, d, h, m, x, _, v, b, w) => {
      const g = d.el = c ? c.el : i(""),
        A = d.anchor = c ? c.anchor : i("");
      let {
        patchFlag: j,
        dynamicChildren: E,
        slotScopeIds: O
      } = d;
      O && (b = b ? b.concat(O) : O), c == null ? (r(g, h, m), r(A, h, m), je(d
          .children || [], h, A, x, _, v, b, w)) : j > 0 && j & 64 && E && c
        .dynamicChildren ? (Ye(c.dynamicChildren, E, h, x, _, v, b), (d.key !=
          null || x && d === x.subTree) && Dr(c, d, !0)) : q(c, d, h, A, x, _,
          v, b, w)
    }, It = (c, d, h, m, x, _, v, b, w) => {
      d.slotScopeIds = b, c == null ? d.shapeFlag & 512 ? x.ctx.activate(d, h,
        m, v, w) : ms(d, h, m, x, _, v, w) : oo(c, d, w)
    }, ms = (c, d, h, m, x, _, v) => {
      const b = c.component = Vi(c, m, x);
      if (Cr(c) && (b.ctx.renderer = bt), Ni(b), b.asyncDep) {
        if (x && x.registerDep(b, ae), !c.el) {
          const w = b.subTree = H(at);
          ee(null, w, d, h)
        }
      } else ae(b, c, d, h, x, _, v)
    }, oo = (c, d, h) => {
      const m = d.component = c.component;
      if (Wl(c, d, h))
        if (m.asyncDep && !m.asyncResolved) {
          X(m, d, h);
          return
        } else m.next = d, Ll(m.update), m.effect.dirty = !0, m.update();
      else d.el = c.el, m.vnode = d
    }, ae = (c, d, h, m, x, _, v) => {
      const b = () => {
          if (c.isMounted) {
            let {
              next: A,
              bu: j,
              u: E,
              parent: O,
              vnode: B
            } = c;
            {
              const ut = Lr(c);
              if (ut) {
                A && (A.el = B.el, X(c, A, v)), ut.asyncDep.then(() => {
                  c.isUnmounted || b()
                });
                return
              }
            }
            let N = A,
              Y;
            et(c, !1), A ? (A.el = B.el, X(c, A, v)) : A = B, j && Kt(j), (Y = A
              .props && A.props.onVnodeBeforeUpdate) && Te(Y, O, A, B), et(c,
              !0);
            const se = ws(c),
              ve = c.subTree;
            c.subTree = se, V(ve, se, y(ve.el), Mt(ve), c, x, _), A.el = se.el,
              N === null && ql(c, se.el), E && de(E, x), (Y = A.props && A.props
                .onVnodeUpdated) && de(() => Te(Y, O, A, B), x)
          } else {
            let A;
            const {
              el: j,
              props: E
            } = d, {
              bm: O,
              m: B,
              parent: N
            } = c, Y = zt(d);
            if (et(c, !1), O && Kt(O), !Y && (A = E && E.onVnodeBeforeMount) &&
              Te(A, N, d), et(c, !0), j && no) {
              const se = () => {
                c.subTree = ws(c), no(j, c.subTree, c, x, null)
              };
              Y ? d.type.__asyncLoader().then(() => !c.isUnmounted && se()) :
                se()
            } else {
              const se = c.subTree = ws(c);
              V(null, se, h, m, c, x, _), d.el = se.el
            }
            if (B && de(B, x), !Y && (A = E && E.onVnodeMounted)) {
              const se = d;
              de(() => Te(A, N, se), x)
            }(d.shapeFlag & 256 || N && zt(N.vnode) && N.vnode.shapeFlag &
            256) && c.a && de(c.a, x), c.isMounted = !0, d = h = m = null
          }
        },
        w = c.effect = new Us(b, we, () => Qs(g), c.scope),
        g = c.update = () => {
          w.dirty && w.run()
        };
      g.id = c.uid, et(c, !0), g()
    }, X = (c, d, h) => {
      d.component = c;
      const m = c.vnode.props;
      c.vnode = d, c.next = null, ki(c, d.props, m, h), Ei(c, d.children, h),
        Ge(), yo(c), Je()
    }, q = (c, d, h, m, x, _, v, b, w = !1) => {
      const g = c && c.children,
        A = c ? c.shapeFlag : 0,
        j = d.children,
        {
          patchFlag: E,
          shapeFlag: O
        } = d;
      if (E > 0) {
        if (E & 128) {
          Bt(g, j, h, m, x, _, v, b, w);
          return
        } else if (E & 256) {
          Xe(g, j, h, m, x, _, v, b, w);
          return
        }
      }
      O & 8 ? (A & 16 && Be(g, x, _), j !== g && p(h, j)) : A & 16 ? O & 16 ?
        Bt(g, j, h, m, x, _, v, b, w) : Be(g, x, _, !0) : (A & 8 && p(h, ""),
          O & 16 && je(j, h, m, x, _, v, b, w))
    }, Xe = (c, d, h, m, x, _, v, b, w) => {
      c = c || dt, d = d || dt;
      const g = c.length,
        A = d.length,
        j = Math.min(g, A);
      let E;
      for (E = 0; E < j; E++) {
        const O = d[E] = w ? Ue(d[E]) : Oe(d[E]);
        V(c[E], O, h, null, x, _, v, b, w)
      }
      g > A ? Be(c, x, _, !0, !1, j) : je(d, h, m, x, _, v, b, w, j)
    }, Bt = (c, d, h, m, x, _, v, b, w) => {
      let g = 0;
      const A = d.length;
      let j = c.length - 1,
        E = A - 1;
      for (; g <= j && g <= E;) {
        const O = c[g],
          B = d[g] = w ? Ue(d[g]) : Oe(d[g]);
        if (wt(O, B)) V(O, B, h, null, x, _, v, b, w);
        else break;
        g++
      }
      for (; g <= j && g <= E;) {
        const O = c[j],
          B = d[E] = w ? Ue(d[E]) : Oe(d[E]);
        if (wt(O, B)) V(O, B, h, null, x, _, v, b, w);
        else break;
        j--, E--
      }
      if (g > j) {
        if (g <= E) {
          const O = E + 1,
            B = O < A ? d[O].el : m;
          for (; g <= E;) V(null, d[g] = w ? Ue(d[g]) : Oe(d[g]), h, B, x, _, v,
            b, w), g++
        }
      } else if (g > E)
        for (; g <= j;) Fe(c[g], x, _, !0), g++;
      else {
        const O = g,
          B = g,
          N = new Map;
        for (g = B; g <= E; g++) {
          const xe = d[g] = w ? Ue(d[g]) : Oe(d[g]);
          xe.key != null && N.set(xe.key, g)
        }
        let Y, se = 0;
        const ve = E - B + 1;
        let ut = !1,
          ao = 0;
        const _t = new Array(ve);
        for (g = 0; g < ve; g++) _t[g] = 0;
        for (g = O; g <= j; g++) {
          const xe = c[g];
          if (se >= ve) {
            Fe(xe, x, _, !0);
            continue
          }
          let Se;
          if (xe.key != null) Se = N.get(xe.key);
          else
            for (Y = B; Y <= E; Y++)
              if (_t[Y - B] === 0 && wt(xe, d[Y])) {
                Se = Y;
                break
              } Se === void 0 ? Fe(xe, x, _, !0) : (_t[Se - B] = g + 1, Se >=
            ao ? ao = Se : ut = !0, V(xe, d[Se], h, null, x, _, v, b, w), se++
            )
        }
        const co = ut ? Ti(_t) : dt;
        for (Y = co.length - 1, g = ve - 1; g >= 0; g--) {
          const xe = B + g,
            Se = d[xe],
            uo = xe + 1 < A ? d[xe + 1].el : m;
          _t[g] === 0 ? V(null, Se, h, uo, x, _, v, b, w) : ut && (Y < 0 ||
            g !== co[Y] ? Ze(Se, h, uo, 2) : Y--)
        }
      }
    }, Ze = (c, d, h, m, x = null) => {
      const {
        el: _,
        type: v,
        transition: b,
        children: w,
        shapeFlag: g
      } = c;
      if (g & 6) {
        Ze(c.component.subTree, d, h, m);
        return
      }
      if (g & 128) {
        c.suspense.move(d, h, m);
        return
      }
      if (g & 64) {
        v.move(c, d, h, bt);
        return
      }
      if (v === z) {
        r(_, d, h);
        for (let j = 0; j < w.length; j++) Ze(w[j], d, h, m);
        r(c.anchor, d, h);
        return
      }
      if (v === qt) {
        W(c, d, h);
        return
      }
      if (m !== 2 && g & 1 && b)
        if (m === 0) b.beforeEnter(_), r(_, d, h), de(() => b.enter(_), x);
        else {
          const {
            leave: j,
            delayLeave: E,
            afterLeave: O
          } = b, B = () => r(_, d, h), N = () => {
            j(_, () => {
              B(), O && O()
            })
          };
          E ? E(_, B, N) : N()
        }
      else r(_, d, h)
    }, Fe = (c, d, h, m = !1, x = !1) => {
      const {
        type: _,
        props: v,
        ref: b,
        children: w,
        dynamicChildren: g,
        shapeFlag: A,
        patchFlag: j,
        dirs: E
      } = c;
      if (b != null && Ms(b, null, h, c, !0), A & 256) {
        d.ctx.deactivate(c);
        return
      }
      const O = A & 1 && E,
        B = !zt(c);
      let N;
      if (B && (N = v && v.onVnodeBeforeUnmount) && Te(N, d, c), A & 6) Yr(c
        .component, h, m);
      else {
        if (A & 128) {
          c.suspense.unmount(h, m);
          return
        }
        O && Qe(c, null, d, "beforeUnmount"), A & 64 ? c.type.remove(c, d, h, x,
          bt, m) : g && (_ !== z || j > 0 && j & 64) ? Be(g, d, h, !1, !0) : (
          _ === z && j & 384 || !x && A & 16) && Be(w, d, h), m && ro(c)
      }(B && (N = v && v.onVnodeUnmounted) || O) && de(() => {
        N && Te(N, d, c), O && Qe(c, null, d, "unmounted")
      }, h)
    }, ro = c => {
      const {
        type: d,
        el: h,
        anchor: m,
        transition: x
      } = c;
      if (d === z) {
        Jr(h, m);
        return
      }
      if (d === qt) {
        te(c);
        return
      }
      const _ = () => {
        o(h), x && !x.persisted && x.afterLeave && x.afterLeave()
      };
      if (c.shapeFlag & 1 && x && !x.persisted) {
        const {
          leave: v,
          delayLeave: b
        } = x, w = () => v(h, _);
        b ? b(c.el, _, w) : w()
      } else _()
    }, Jr = (c, d) => {
      let h;
      for (; c !== d;) h = C(c), o(c), c = h;
      o(d)
    }, Yr = (c, d, h) => {
      const {
        bum: m,
        scope: x,
        update: _,
        subTree: v,
        um: b
      } = c;
      m && Kt(m), x.stop(), _ && (_.active = !1, Fe(v, c, d, h)), b && de(b, d),
        de(() => {
          c.isUnmounted = !0
        }, d), d && d.pendingBranch && !d.isUnmounted && c.asyncDep && !c
        .asyncResolved && c.suspenseId === d.pendingId && (d.deps--, d.deps ===
          0 && d.resolve())
    }, Be = (c, d, h, m = !1, x = !1, _ = 0) => {
      for (let v = _; v < c.length; v++) Fe(c[v], d, h, m, x)
    }, Mt = c => c.shapeFlag & 6 ? Mt(c.component.subTree) : c.shapeFlag & 128 ?
    c.suspense.next() : C(c.anchor || c.el);
  let xs = !1;
  const lo = (c, d, h) => {
      c == null ? d._vnode && Fe(d._vnode, null, null, !0) : V(d._vnode || null,
          c, d, null, null, null, h), xs || (xs = !0, yo(), br(), xs = !1), d
        ._vnode = c
    },
    bt = {
      p: V,
      um: Fe,
      m: Ze,
      r: ro,
      mt: ms,
      mc: je,
      pc: q,
      pbc: Ye,
      n: Mt,
      o: e
    };
  let io, no;
  return {
    render: lo,
    hydrate: io,
    createApp: wi(lo, io)
  }
}

function ks({
  type: e,
  props: t
}, s) {
  return s === "svg" && e === "foreignObject" || s === "mathml" && e ===
    "annotation-xml" && t && t.encoding && t.encoding.includes("html") ?
    void 0 : s
}

function et({
  effect: e,
  update: t
}, s) {
  e.allowRecurse = t.allowRecurse = s
}

function Si(e, t) {
  return (!e || e && !e.pendingBranch) && t && !t.persisted
}

function Dr(e, t, s = !1) {
  const r = e.children,
    o = t.children;
  if (F(r) && F(o))
    for (let l = 0; l < r.length; l++) {
      const n = r[l];
      let i = o[l];
      i.shapeFlag & 1 && !i.dynamicChildren && ((i.patchFlag <= 0 || i
        .patchFlag === 32) && (i = o[l] = Ue(o[l]), i.el = n.el), s || Dr(n,
        i)), i.type === cs && (i.el = n.el)
    }
}

function Ti(e) {
  const t = e.slice(),
    s = [0];
  let r, o, l, n, i;
  const u = e.length;
  for (r = 0; r < u; r++) {
    const f = e[r];
    if (f !== 0) {
      if (o = s[s.length - 1], e[o] < f) {
        t[r] = o, s.push(r);
        continue
      }
      for (l = 0, n = s.length - 1; l < n;) i = l + n >> 1, e[s[i]] < f ? l =
        i + 1 : n = i;
      f < e[s[l]] && (l > 0 && (t[r] = s[l - 1]), s[l] = r)
    }
  }
  for (l = s.length, n = s[l - 1]; l-- > 0;) s[l] = n, n = t[n];
  return s
}

function Lr(e) {
  const t = e.subTree.component;
  if (t) return t.asyncDep && !t.asyncResolved ? t : Lr(t)
}
const Oi = e => e.__isTeleport,
  z = Symbol.for("v-fgt"),
  cs = Symbol.for("v-txt"),
  at = Symbol.for("v-cmt"),
  qt = Symbol.for("v-stc"),
  jt = [];
let Ae = null;

function T(e = !1) {
  jt.push(Ae = e ? null : [])
}

function Pi() {
  jt.pop(), Ae = jt[jt.length - 1] || null
}
let Tt = 1;

function Po(e) {
  Tt += e
}

function Vr(e) {
  return e.dynamicChildren = Tt > 0 ? Ae || dt : null, Pi(), Tt > 0 && Ae && Ae
    .push(e), e
}

function P(e, t, s, r, o, l) {
  return Vr(a(e, t, s, r, o, l, !0))
}

function $i(e, t, s, r, o) {
  return Vr(H(e, t, s, r, o, !0))
}

function Ii(e) {
  return e ? e.__v_isVNode === !0 : !1
}

function wt(e, t) {
  return e.type === t.type && e.key === t.key
}
const Nr = ({
    key: e
  }) => e ?? null,
  Gt = ({
    ref: e,
    ref_key: t,
    ref_for: s
  }) => (typeof e == "number" && (e = "" + e), e != null ? Q(e) || ge(e) || I(
    e) ? {
      i: he,
      r: e,
      k: t,
      f: !!s
    } : e : null);

function a(e, t = null, s = null, r = 0, o = null, l = e === z ? 0 : 1, n = !1,
  i = !1) {
  const u = {
    __v_isVNode: !0,
    __v_skip: !0,
    type: e,
    props: t,
    key: t && Nr(t),
    ref: t && Gt(t),
    scopeId: yr,
    slotScopeIds: null,
    children: s,
    component: null,
    suspense: null,
    ssContent: null,
    ssFallback: null,
    dirs: null,
    transition: null,
    el: null,
    anchor: null,
    target: null,
    targetAnchor: null,
    staticCount: 0,
    shapeFlag: l,
    patchFlag: r,
    dynamicProps: o,
    dynamicChildren: null,
    appContext: null,
    ctx: he
  };
  return i ? (so(u, s), l & 128 && e.normalize(u)) : s && (u.shapeFlag |= Q(s) ?
      8 : 16), Tt > 0 && !n && Ae && (u.patchFlag > 0 || l & 6) && u
    .patchFlag !== 32 && Ae.push(u), u
}
const H = Bi;

function Bi(e, t = null, s = null, r = 0, o = null, l = !1) {
  if ((!e || e === Gl) && (e = at), Ii(e)) {
    const i = pt(e, t, !0);
    return s && so(i, s), Tt > 0 && !l && Ae && (i.shapeFlag & 6 ? Ae[Ae
      .indexOf(e)] = i : Ae.push(i)), i.patchFlag |= -2, i
  }
  if (Wi(e) && (e = e.__vccOpts), t) {
    t = Mi(t);
    let {
      class: i,
      style: u
    } = t;
    i && !Q(i) && (t.class = Z(i)), J(u) && (fr(u) && !F(u) && (u = re({}, u)),
      t.style = Le(u))
  }
  const n = Q(e) ? 1 : Yl(e) ? 128 : Oi(e) ? 64 : J(e) ? 4 : I(e) ? 2 : 0;
  return a(e, t, s, r, o, n, l, !0)
}

function Mi(e) {
  return e ? fr(e) || Pr(e) ? re({}, e) : e : null
}

function pt(e, t, s = !1, r = !1) {
  const {
    props: o,
    ref: l,
    patchFlag: n,
    children: i,
    transition: u
  } = e, f = t ? Ri(o || {}, t) : o, p = {
    __v_isVNode: !0,
    __v_skip: !0,
    type: e.type,
    props: f,
    key: f && Nr(f),
    ref: t && t.ref ? s && l ? F(l) ? l.concat(Gt(t)) : [l, Gt(t)] : Gt(t) :
      l,
    scopeId: e.scopeId,
    slotScopeIds: e.slotScopeIds,
    children: i,
    target: e.target,
    targetAnchor: e.targetAnchor,
    staticCount: e.staticCount,
    shapeFlag: e.shapeFlag,
    patchFlag: t && e.type !== z ? n === -1 ? 16 : n | 16 : n,
    dynamicProps: e.dynamicProps,
    dynamicChildren: e.dynamicChildren,
    appContext: e.appContext,
    dirs: e.dirs,
    transition: u,
    component: e.component,
    suspense: e.suspense,
    ssContent: e.ssContent && pt(e.ssContent),
    ssFallback: e.ssFallback && pt(e.ssFallback),
    el: e.el,
    anchor: e.anchor,
    ctx: e.ctx,
    ce: e.ce
  };
  return u && r && (p.transition = u.clone(p)), p
}

function M(e = " ", t = 0) {
  return H(cs, null, e, t)
}

function us(e, t) {
  const s = H(qt, null, e);
  return s.staticCount = t, s
}

function tt(e = "", t = !1) {
  return t ? (T(), $i(at, null, e)) : H(at, null, e)
}

function Oe(e) {
  return e == null || typeof e == "boolean" ? H(at) : F(e) ? H(z, null, e
  .slice()) : typeof e == "object" ? Ue(e) : H(cs, null, String(e))
}

function Ue(e) {
  return e.el === null && e.patchFlag !== -1 || e.memo ? e : pt(e)
}

function so(e, t) {
  let s = 0;
  const {
    shapeFlag: r
  } = e;
  if (t == null) t = null;
  else if (F(t)) s = 16;
  else if (typeof t == "object")
    if (r & 65) {
      const o = t.default;
      o && (o._c && (o._d = !1), so(e, o()), o._c && (o._d = !0));
      return
    } else {
      s = 32;
      const o = t._;
      !o && !Pr(t) ? t._ctx = he : o === 3 && he && (he.slots._ === 1 ? t._ =
        1 : (t._ = 2, e.patchFlag |= 1024))
    }
  else I(t) ? (t = {
    default: t,
    _ctx: he
  }, s = 32) : (t = String(t), r & 64 ? (s = 16, t = [M(t)]) : s = 8);
  e.children = t, e.shapeFlag |= s
}

function Ri(...e) {
  const t = {};
  for (let s = 0; s < e.length; s++) {
    const r = e[s];
    for (const o in r)
      if (o === "class") t.class !== r.class && (t.class = Z([t.class, r
        .class]));
      else if (o === "style") t.style = Le([t.style, r.style]);
    else if (ss(o)) {
      const l = t[o],
        n = r[o];
      n && l !== n && !(F(l) && l.includes(n)) && (t[o] = l ? [].concat(l, n) :
        n)
    } else o !== "" && (t[o] = r[o])
  }
  return t
}

function Te(e, t, s, r = null) {
  Ce(e, t, 7, [s, r])
}
const Di = Sr();
let Li = 0;

function Vi(e, t, s) {
  const r = e.type,
    o = (t ? t.appContext : e.appContext) || Di,
    l = {
      uid: Li++,
      vnode: e,
      type: r,
      parent: t,
      appContext: o,
      root: null,
      next: null,
      subTree: null,
      effect: null,
      update: null,
      scope: new cl(!0),
      render: null,
      proxy: null,
      exposed: null,
      exposeProxy: null,
      withProxy: null,
      provides: t ? t.provides : Object.create(o.provides),
      accessCache: null,
      renderCache: [],
      components: null,
      directives: null,
      propsOptions: Ir(r, o),
      emitsOptions: wr(r, o),
      emit: null,
      emitted: null,
      propsDefaults: G,
      inheritAttrs: r.inheritAttrs,
      ctx: G,
      data: G,
      props: G,
      attrs: G,
      slots: G,
      refs: G,
      setupState: G,
      setupContext: null,
      attrsProxy: null,
      slotsProxy: null,
      suspense: s,
      suspenseId: s ? s.pendingId : 0,
      asyncDep: null,
      asyncResolved: !1,
      isMounted: !1,
      isUnmounted: !1,
      isDeactivated: !1,
      bc: null,
      c: null,
      bm: null,
      m: null,
      bu: null,
      u: null,
      um: null,
      bum: null,
      da: null,
      a: null,
      rtg: null,
      rtc: null,
      ec: null,
      sp: null
    };
  return l.ctx = {
    _: l
  }, l.root = t ? t.root : l, l.emit = Hl.bind(null, l), e.ce && e.ce(l), l
}
let ne = null,
  es, Rs;
{
  const e = Xo(),
    t = (s, r) => {
      let o;
      return (o = e[s]) || (o = e[s] = []), o.push(r), l => {
        o.length > 1 ? o.forEach(n => n(l)) : o[0](l)
      }
    };
  es = t("__VUE_INSTANCE_SETTERS__", s => ne = s), Rs = t("__VUE_SSR_SETTERS__",
    s => ds = s)
}
const Pt = e => {
    const t = ne;
    return es(e), e.scope.on(), () => {
      e.scope.off(), es(t)
    }
  },
  $o = () => {
    ne && ne.scope.off(), es(null)
  };

function Hr(e) {
  return e.vnode.shapeFlag & 4
}
let ds = !1;

function Ni(e, t = !1) {
  t && Rs(t);
  const {
    props: s,
    children: r
  } = e.vnode, o = Hr(e);
  vi(e, s, o, t), Ci(e, r);
  const l = o ? Hi(e, t) : void 0;
  return t && Rs(!1), l
}

function Hi(e, t) {
  const s = e.type;
  e.accessCache = Object.create(null), e.proxy = new Proxy(e.ctx, hi);
  const {
    setup: r
  } = s;
  if (r) {
    const o = e.setupContext = r.length > 1 ? Ki(e) : null,
      l = Pt(e);
    Ge();
    const n = We(r, e, 0, [e.props, o]);
    if (Je(), l(), qo(n)) {
      if (n.then($o, $o), t) return n.then(i => {
        Io(e, i, t)
      }).catch(i => {
        is(i, e, 0)
      });
      e.asyncDep = n
    } else Io(e, n, t)
  } else Ur(e, t)
}

function Io(e, t, s) {
  I(t) ? e.type.__ssrInlineRender ? e.ssrRender = t : e.render = t : J(t) && (e
    .setupState = pr(t)), Ur(e, s)
}
let Bo;

function Ur(e, t, s) {
  const r = e.type;
  if (!e.render) {
    if (!t && Bo && !r.render) {
      const o = r.template || eo(e).template;
      if (o) {
        const {
          isCustomElement: l,
          compilerOptions: n
        } = e.appContext.config, {
          delimiters: i,
          compilerOptions: u
        } = r, f = re(re({
          isCustomElement: l,
          delimiters: i
        }, n), u);
        r.render = Bo(o, f)
      }
    }
    e.render = r.render || we
  } {
    const o = Pt(e);
    Ge();
    try {
      pi(e)
    } finally {
      Je(), o()
    }
  }
}
const Ui = {
  get(e, t) {
    return pe(e, "get", ""), e[t]
  }
};

function Ki(e) {
  const t = s => {
    e.exposed = s || {}
  };
  return {
    attrs: new Proxy(e.attrs, Ui),
    slots: e.slots,
    emit: e.emit,
    expose: t
  }
}

function fs(e) {
  if (e.exposed) return e.exposeProxy || (e.exposeProxy = new Proxy(pr(Pl(e
    .exposed)), {
    get(t, s) {
      if (s in t) return t[s];
      if (s in Ct) return Ct[s](e)
    },
    has(t, s) {
      return s in t || s in Ct
    }
  }))
}

function zi(e, t = !0) {
  return I(e) ? e.displayName || e.name : e.name || t && e.__name
}

function Wi(e) {
  return I(e) && "__vccOpts" in e
}
const qi = (e, t) => $l(e, t, ds),
  Gi = "3.4.27";
/**
 * @vue/runtime-dom v3.4.27
 * (c) 2018-present Yuxi (Evan) You and Vue contributors
 * @license MIT
 **/
const Ji = "http://www.w3.org/2000/svg",
  Yi = "http://www.w3.org/1998/Math/MathML",
  Ke = typeof document < "u" ? document : null,
  Mo = Ke && Ke.createElement("template"),
  Xi = {
    insert: (e, t, s) => {
      t.insertBefore(e, s || null)
    },
    remove: e => {
      const t = e.parentNode;
      t && t.removeChild(e)
    },
    createElement: (e, t, s, r) => {
      const o = t === "svg" ? Ke.createElementNS(Ji, e) : t === "mathml" ? Ke
        .createElementNS(Yi, e) : Ke.createElement(e, s ? {
          is: s
        } : void 0);
      return e === "select" && r && r.multiple != null && o.setAttribute(
        "multiple", r.multiple), o
    },
    createText: e => Ke.createTextNode(e),
    createComment: e => Ke.createComment(e),
    setText: (e, t) => {
      e.nodeValue = t
    },
    setElementText: (e, t) => {
      e.textContent = t
    },
    parentNode: e => e.parentNode,
    nextSibling: e => e.nextSibling,
    querySelector: e => Ke.querySelector(e),
    setScopeId(e, t) {
      e.setAttribute(t, "")
    },
    insertStaticContent(e, t, s, r, o, l) {
      const n = s ? s.previousSibling : t.lastChild;
      if (o && (o === l || o.nextSibling))
        for (; t.insertBefore(o.cloneNode(!0), s), !(o === l || !(o = o
            .nextSibling)););
      else {
        Mo.innerHTML = r === "svg" ? `<svg>${e}</svg>` : r === "mathml" ?
          `<math>${e}</math>` : e;
        const i = Mo.content;
        if (r === "svg" || r === "mathml") {
          const u = i.firstChild;
          for (; u.firstChild;) i.appendChild(u.firstChild);
          i.removeChild(u)
        }
        t.insertBefore(i, s)
      }
      return [n ? n.nextSibling : t.firstChild, s ? s.previousSibling : t
        .lastChild
      ]
    }
  },
  Zi = Symbol("_vtc");

function Qi(e, t, s) {
  const r = e[Zi];
  r && (t = (t ? [t, ...r] : [...r]).join(" ")), t == null ? e.removeAttribute(
    "class") : s ? e.setAttribute("class", t) : e.className = t
}
const ts = Symbol("_vod"),
  Kr = Symbol("_vsh"),
  D = {
    beforeMount(e, {
      value: t
    }, {
      transition: s
    }) {
      e[ts] = e.style.display === "none" ? "" : e.style.display, s && t ? s
        .beforeEnter(e) : yt(e, t)
    },
    mounted(e, {
      value: t
    }, {
      transition: s
    }) {
      s && t && s.enter(e)
    },
    updated(e, {
      value: t,
      oldValue: s
    }, {
      transition: r
    }) {
      !t != !s && (r ? t ? (r.beforeEnter(e), yt(e, !0), r.enter(e)) : r.leave(
        e, () => {
          yt(e, !1)
        }) : yt(e, t))
    },
    beforeUnmount(e, {
      value: t
    }) {
      yt(e, t)
    }
  };

function yt(e, t) {
  e.style.display = t ? e[ts] : "none", e[Kr] = !t
}
const en = Symbol(""),
  tn = /(^|;)\s*display\s*:/;

function sn(e, t, s) {
  const r = e.style,
    o = Q(s);
  let l = !1;
  if (s && !o) {
    if (t)
      if (Q(t))
        for (const n of t.split(";")) {
          const i = n.slice(0, n.indexOf(":")).trim();
          s[i] == null && Jt(r, i, "")
        } else
          for (const n in t) s[n] == null && Jt(r, n, "");
    for (const n in s) n === "display" && (l = !0), Jt(r, n, s[n])
  } else if (o) {
    if (t !== s) {
      const n = r[en];
      n && (s += ";" + n), r.cssText = s, l = tn.test(s)
    }
  } else t && e.removeAttribute("style");
  ts in e && (e[ts] = l ? r.display : "", e[Kr] && (r.display = "none"))
}
const Ro = /\s*!important$/;

function Jt(e, t, s) {
  if (F(s)) s.forEach(r => Jt(e, t, r));
  else if (s == null && (s = ""), t.startsWith("--")) e.setProperty(t, s);
  else {
    const r = on(e, t);
    Ro.test(s) ? e.setProperty(ct(r), s.replace(Ro, ""), "important") : e[r] = s
  }
}
const Do = ["Webkit", "Moz", "ms"],
  As = {};

function on(e, t) {
  const s = As[t];
  if (s) return s;
  let r = $e(t);
  if (r !== "filter" && r in e) return As[t] = r;
  r = rs(r);
  for (let o = 0; o < Do.length; o++) {
    const l = Do[o] + r;
    if (l in e) return As[t] = l
  }
  return t
}
const Lo = "http://www.w3.org/1999/xlink";

function rn(e, t, s, r, o) {
  if (r && t.startsWith("xlink:")) s == null ? e.removeAttributeNS(Lo, t.slice(
    6, t.length)) : e.setAttributeNS(Lo, t, s);
  else {
    const l = nl(t);
    s == null || l && !Zo(s) ? e.removeAttribute(t) : e.setAttribute(t, l ? "" :
      s)
  }
}

function ln(e, t, s, r, o, l, n) {
  if (t === "innerHTML" || t === "textContent") {
    r && n(r, o, l), e[t] = s ?? "";
    return
  }
  const i = e.tagName;
  if (t === "value" && i !== "PROGRESS" && !i.includes("-")) {
    const f = i === "OPTION" ? e.getAttribute("value") || "" : e.value,
      p = s ?? "";
    (f !== p || !("_value" in e)) && (e.value = p), s == null && e
      .removeAttribute(t), e._value = s;
    return
  }
  let u = !1;
  if (s === "" || s == null) {
    const f = typeof e[t];
    f === "boolean" ? s = Zo(s) : s == null && f === "string" ? (s = "", u = !
      0) : f === "number" && (s = 0, u = !0)
  }
  try {
    e[t] = s
  } catch {}
  u && e.removeAttribute(t)
}

function Me(e, t, s, r) {
  e.addEventListener(t, s, r)
}

function nn(e, t, s, r) {
  e.removeEventListener(t, s, r)
}
const Vo = Symbol("_vei");

function an(e, t, s, r, o = null) {
  const l = e[Vo] || (e[Vo] = {}),
    n = l[t];
  if (r && n) n.value = r;
  else {
    const [i, u] = cn(t);
    if (r) {
      const f = l[t] = fn(r, o);
      Me(e, i, f, u)
    } else n && (nn(e, i, n, u), l[t] = void 0)
  }
}
const No = /(?:Once|Passive|Capture)$/;

function cn(e) {
  let t;
  if (No.test(e)) {
    t = {};
    let r;
    for (; r = e.match(No);) e = e.slice(0, e.length - r[0].length), t[r[0]
      .toLowerCase()] = !0
  }
  return [e[2] === ":" ? e.slice(3) : ct(e.slice(2)), t]
}
let Cs = 0;
const un = Promise.resolve(),
  dn = () => Cs || (un.then(() => Cs = 0), Cs = Date.now());

function fn(e, t) {
  const s = r => {
    if (!r._vts) r._vts = Date.now();
    else if (r._vts <= s.attached) return;
    Ce(hn(r, s.value), t, 5, [r])
  };
  return s.value = e, s.attached = dn(), s
}

function hn(e, t) {
  if (F(t)) {
    const s = e.stopImmediatePropagation;
    return e.stopImmediatePropagation = () => {
      s.call(e), e._stopped = !0
    }, t.map(r => o => !o._stopped && r && r(o))
  } else return t
}
const Ho = e => e.charCodeAt(0) === 111 && e.charCodeAt(1) === 110 && e
  .charCodeAt(2) > 96 && e.charCodeAt(2) < 123,
  pn = (e, t, s, r, o, l, n, i, u) => {
    const f = o === "svg";
    t === "class" ? Qi(e, r, f) : t === "style" ? sn(e, s, r) : ss(t) ? Ls(t) ||
      an(e, t, s, r, n) : (t[0] === "." ? (t = t.slice(1), !0) : t[0] === "^" ?
        (t = t.slice(1), !1) : mn(e, t, r, f)) ? ln(e, t, r, l, n, i, u) : (
        t === "true-value" ? e._trueValue = r : t === "false-value" && (e
          ._falseValue = r), rn(e, t, r, f))
  };

function mn(e, t, s, r) {
  if (r) return !!(t === "innerHTML" || t === "textContent" || t in e && Ho(
    t) && I(s));
  if (t === "spellcheck" || t === "draggable" || t === "translate" || t ===
    "form" || t === "list" && e.tagName === "INPUT" || t === "type" && e
    .tagName === "TEXTAREA") return !1;
  if (t === "width" || t === "height") {
    const o = e.tagName;
    if (o === "IMG" || o === "VIDEO" || o === "CANVAS" || o === "SOURCE")
    return !1
  }
  return Ho(t) && Q(s) ? !1 : t in e
}
const qe = e => {
  const t = e.props["onUpdate:modelValue"] || !1;
  return F(t) ? s => Kt(t, s) : t
};

function xn(e) {
  e.target.composing = !0
}

function Uo(e) {
  const t = e.target;
  t.composing && (t.composing = !1, t.dispatchEvent(new Event("input")))
}
const ye = Symbol("_assign"),
  _e = {
    created(e, {
      modifiers: {
        lazy: t,
        trim: s,
        number: r
      }
    }, o) {
      e[ye] = qe(o);
      const l = r || o.props && o.props.type === "number";
      Me(e, t ? "change" : "input", n => {
        if (n.target.composing) return;
        let i = e.value;
        s && (i = i.trim()), l && (i = Yt(i)), e[ye](i)
      }), s && Me(e, "change", () => {
        e.value = e.value.trim()
      }), t || (Me(e, "compositionstart", xn), Me(e, "compositionend", Uo),
        Me(e, "change", Uo))
    },
    mounted(e, {
      value: t
    }) {
      e.value = t ?? ""
    },
    beforeUpdate(e, {
      value: t,
      modifiers: {
        lazy: s,
        trim: r,
        number: o
      }
    }, l) {
      if (e[ye] = qe(l), e.composing) return;
      const n = (o || e.type === "number") && !/^0\d/.test(e.value) ? Yt(e
          .value) : e.value,
        i = t ?? "";
      n !== i && (document.activeElement === e && e.type !== "range" && (s ||
        r && e.value.trim() === i) || (e.value = i))
    }
  },
  zr = {
    deep: !0,
    created(e, t, s) {
      e[ye] = qe(s), Me(e, "change", () => {
        const r = e._modelValue,
          o = mt(e),
          l = e.checked,
          n = e[ye];
        if (F(r)) {
          const i = Hs(r, o),
            u = i !== -1;
          if (l && !u) n(r.concat(o));
          else if (!l && u) {
            const f = [...r];
            f.splice(i, 1), n(f)
          }
        } else if (xt(r)) {
          const i = new Set(r);
          l ? i.add(o) : i.delete(o), n(i)
        } else n(Wr(e, l))
      })
    },
    mounted: Ko,
    beforeUpdate(e, t, s) {
      e[ye] = qe(s), Ko(e, t, s)
    }
  };

function Ko(e, {
  value: t,
  oldValue: s
}, r) {
  e._modelValue = t, F(t) ? e.checked = Hs(t, r.props.value) > -1 : xt(t) ? e
    .checked = t.has(r.props.value) : t !== s && (e.checked = nt(t, Wr(e, !0)))
}
const gn = {
    created(e, {
      value: t
    }, s) {
      e.checked = nt(t, s.props.value), e[ye] = qe(s), Me(e, "change", () => {
        e[ye](mt(e))
      })
    },
    beforeUpdate(e, {
      value: t,
      oldValue: s
    }, r) {
      e[ye] = qe(r), t !== s && (e.checked = nt(t, r.props.value))
    }
  },
  bn = {
    deep: !0,
    created(e, {
      value: t,
      modifiers: {
        number: s
      }
    }, r) {
      const o = xt(t);
      Me(e, "change", () => {
        const l = Array.prototype.filter.call(e.options, n => n.selected)
          .map(n => s ? Yt(mt(n)) : mt(n));
        e[ye](e.multiple ? o ? new Set(l) : l : l[0]), e._assigning = !0,
          xr(() => {
            e._assigning = !1
          })
      }), e[ye] = qe(r)
    },
    mounted(e, {
      value: t,
      modifiers: {
        number: s
      }
    }) {
      zo(e, t)
    },
    beforeUpdate(e, t, s) {
      e[ye] = qe(s)
    },
    updated(e, {
      value: t,
      modifiers: {
        number: s
      }
    }) {
      e._assigning || zo(e, t)
    }
  };

function zo(e, t, s) {
  const r = e.multiple,
    o = F(t);
  if (!(r && !o && !xt(t))) {
    for (let l = 0, n = e.options.length; l < n; l++) {
      const i = e.options[l],
        u = mt(i);
      if (r)
        if (o) {
          const f = typeof u;
          f === "string" || f === "number" ? i.selected = t.some(p => String(
            p) === String(u)) : i.selected = Hs(t, u) > -1
        } else i.selected = t.has(u);
      else if (nt(mt(i), t)) {
        e.selectedIndex !== l && (e.selectedIndex = l);
        return
      }
    }!r && e.selectedIndex !== -1 && (e.selectedIndex = -1)
  }
}

function mt(e) {
  return "_value" in e ? e._value : e.value
}

function Wr(e, t) {
  const s = t ? "_trueValue" : "_falseValue";
  return s in e ? e[s] : t
}
const _n = {
  created(e, t, s) {
    Ut(e, t, s, null, "created")
  },
  mounted(e, t, s) {
    Ut(e, t, s, null, "mounted")
  },
  beforeUpdate(e, t, s, r) {
    Ut(e, t, s, r, "beforeUpdate")
  },
  updated(e, t, s, r) {
    Ut(e, t, s, r, "updated")
  }
};

function wn(e, t) {
  switch (e) {
    case "SELECT":
      return bn;
    case "TEXTAREA":
      return _e;
    default:
      switch (t) {
        case "checkbox":
          return zr;
        case "radio":
          return gn;
        default:
          return _e
      }
  }
}

function Ut(e, t, s, r, o) {
  const n = wn(e.tagName, s.props && s.props.type)[o];
  n && n(e, t, s, r)
}
const yn = {
    esc: "escape",
    space: " ",
    up: "arrow-up",
    left: "arrow-left",
    right: "arrow-right",
    down: "arrow-down",
    delete: "backspace"
  },
  qr = (e, t) => {
    const s = e._withKeys || (e._withKeys = {}),
      r = t.join(".");
    return s[r] || (s[r] = o => {
      if (!("key" in o)) return;
      const l = ct(o.key);
      if (t.some(n => n === l || yn[n] === l)) return e(o)
    })
  },
  vn = re({
    patchProp: pn
  }, Xi);
let Wo;

function kn() {
  return Wo || (Wo = ji(vn))
}
const An = (...e) => {
  const t = kn().createApp(...e),
    {
      mount: s
    } = t;
  return t.mount = r => {
    const o = En(r);
    if (!o) return;
    const l = t._component;
    !I(l) && !l.render && !l.template && (l.template = o.innerHTML), o
      .innerHTML = "";
    const n = s(o, !1, Cn(o));
    return o instanceof Element && (o.removeAttribute("v-cloak"), o
      .setAttribute("data-v-app", "")), n
  }, t
};

function Cn(e) {
  if (e instanceof SVGElement) return "svg";
  if (typeof MathMLElement == "function" && e instanceof MathMLElement)
  return "mathml"
}

function En(e) {
  return Q(e) ? document.querySelector(e) : e
}
async function fe(e = "", t = {}) {
  return (await fetch(`https://s1m1s-adminmenu/${e}`, {
    method: "POST",
    mode: "cors",
    cache: "no-cache",
    credentials: "same-origin",
    headers: {
      "Content-Type": "application/json"
    },
    redirect: "follow",
    referrerPolicy: "no-referrer",
    body: JSON.stringify(t)
  })).json()
}
const ue = (e, t) => {
    const s = e.__vccOpts || e;
    for (const [r, o] of t) s[r] = o;
    return s
  },
  jn = {
    props: {
      show: Boolean,
      admin: Object
    },
    data() {
      return {
        roles: {
          owner: {
            color: "#F1C40F",
            name: "Savininkas"
          },
          dev: {
            color: "#0064C4",
            name: "Developeris"
          },
          pagradmin: {
            color: "#F50202",
            name: "Pagr. Administratorius(-ė)"
          },
          vyradmin: {
            color: "#E91E63",
            name: "Vyr. Administratorius(-ė)"
          },
          admin: {
            color: "#AC0303",
            name: "Administratorius(-ė)"
          },
          vyrsupport: {
            color: "#9B59B6",
            name: "Vyr. Support"
          },
          support: {
            color: "#FE3586",
            name: "Support"
          },
          player: {
            color: "#3A4750",
            name: "Žaidėjas"
          }
          ,player: {
            color: "#3A4750",
            name: "Žaidėjas"
          }
        }
      }
    },
    methods: {
      getHours(e) {
        let t = Math.floor(e / 60 / 60),
          s = Math.floor(e / 60 - t * 60);
        return t + "h " + s + "min"
      }
    }
  },
  Fn = {
    class: "flex flex-col bg-slate-900/80 rounded-3xl z-10 w-1/2"
  },
  Sn = {
    class: "flex flex-col w-full p-10"
  },
  Tn = {
    class: "flex w-full justify-end z-20"
  },
  On = {
    class: "flex text-white -mt-10 mb-2 text-xl font-bold"
  },
  Pn = {
    class: "flex flex-row mb-4"
  },
  $n = {
    class: "flex flex-col"
  },
  In = a("p", {
    class: "text-white mb-2 text-md"
  }, "Atsakytos užklausos", -1),
  Bn = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  },
  Mn = a("i", {
    class: "fa-solid fa-flag text-[#4EABF8] mr-3 ml-2"
  }, null, -1),
  Rn = a("p", {
    class: "text-white mb-2 text-md"
  }, "Išspręstos užklausos", -1),
  Dn = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  },
  Ln = a("i", {
    class: "fa-solid fa-flag-checkered text-[#4EABF8] mr-3 ml-2"
  }, null, -1),
  Vn = a("p", {
    class: "text-white mb-2 text-md"
  }, "Aktyvumas (per visą laiką)", -1),
  Nn = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  },
  Hn = a("i", {
    class: "fa-solid fa-flag-checkered text-[#4EABF8] mr-3 ml-2"
  }, null, -1),
  Un = a("p", {
    class: "text-white mb-2 text-md"
  }, "Įvertinimas", -1),
  Kn = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  },
  zn = a("i", {
    class: "fa-solid fa-thumbs-up text-[#4EABF8] mr-3 ml-2"
  }, null, -1),
  Wn = a("p", {
    class: "text-white mb-2 mt-4 text-lg font-bold"
  }, "Per 7 dienas", -1),
  qn = a("p", {
    class: "text-white mb-2 text-md"
  }, "Aktyvumas", -1),
  Gn = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  },
  Jn = a("i", {
    class: "fa-solid fa-clock text-[#4EABF8] mr-3 ml-2"
  }, null, -1),
  Yn = a("p", {
    class: "text-white mb-2 text-md"
  }, "Atsakytos užklausos", -1),
  Xn = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  },
  Zn = a("i", {
    class: "fa-solid fa-flag text-[#4EABF8] mr-3 ml-2"
  }, null, -1),
  Qn = a("p", {
    class: "text-white mb-2 text-md"
  }, "Išspręstos užklausos", -1),
  ea = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  },
  ta = a("i", {
    class: "fa-solid fa-flag-checkered text-[#4EABF8] mr-3 ml-2"
  }, null, -1);

function sa(e, t, s, r, o, l) {
  return S((T(), P("div", Fn, [S(a("div", Sn, [a("div", Tn, [a("i", {
    class: "fa-solid fa-xmark text-xl text-[#4EABF8] p-2",
    onClick: t[0] || (t[0] = n => e.$emit("closeDialog"))
  })]), a("p", On, k(s.admin.name), 1), a("div", Pn, [a("div", {
    class: "flex flex-row w-auto rounded-lg mr-2 px-2 py-0 leading-normal text-sm text-white",
    style: Le({
      background: o.roles[s.admin.role].color
    })
  }, k(o.roles[s.admin.role].name), 5)]), a("div", $n, [In, a(
    "div", Bn, [Mn, M(" " + k(s.admin.reports), 1)]), Rn, a(
    "div", Dn, [Ln, M(" " + k(s.admin.claimed), 1)]), Vn, a(
    "div", Nn, [Hn, M(" " + k(l.getHours(s.admin.alltime)),
      1)]), Un, a("div", Kn, [zn, M(" " + k(Math.floor(s
      .admin.upvotes / s.admin.downvotes * 100) + "%"),
    1)]), Wn, qn, a("div", Gn, [Jn, M(" " + k(l.getHours(s
    .admin.time)), 1)]), Yn, a("div", Xn, [Zn, M(" " + k(s
    .admin.reports7), 1)]), Qn, a("div", ea, [ta, M(" " + k(
    s.admin.claimed7), 1)])])], 512), [
    [D, s.show]
  ])], 512)), [
    [D, s.show]
  ])
}
const oa = ue(jn, [
    ["render", sa]
  ]),
  ra = {
    props: {
      show: Boolean
    },
    components: {
      admin: oa
    },
    data() {
      return {
        roles: {
          owner: {
            color: "#F1C40F",
            name: "Savininkas"
          },
          dev: {
            color: "#0064C4",
            name: "Developeris"
          },
          pagradmin: {
            color: "#F50202",
            name: "Pagr. Administratorius(-ė)"
          },
          vyradmin: {
            color: "#E91E63",
            name: "Vyr. Administratorius(-ė)"
          },
          admin: {
            color: "#AC0303",
            name: "Administratorius(-ė)"
          },
          vyrsupport: {
            color: "#9B59B6",
            name: "Vyr. Support"
          },
          support: {
            color: "#FE3586",
            name: "Support"
          }
          ,player: {
            color: "#3A4750",
            name: "Žaidėjas"
          }
        },
        sroles: ["owner", "dev", "pagradmin", "vyradmin", "admin", "vyrsupport",
          "support"
        ],
        Admins: [],
        admin: {
          name: "s1m1s",
          role: "dev",
          reports: 200,
          claimed: 100,
          online: !0,
          time: "1h 30 min",
          reports7: 100,
          claimed7: 70,
          upvotes: 10,
          downvotes: 50
        },
        search: "",
        dialog: !1
      }
    },
    watch: {
      show(e) {
        e || this.CloseDialog()
      }
    },
    methods: {
      OpenWindow(e) {
        this.dialog ? this.admin = e : (this.dialog = !0, this.admin = e)
      },
      CloseDialog() {
        this.dialog = !1
      }
    },
    computed: {
      getAdmins() {
        return this.Admins.filter(e => e.name.toLowerCase().includes(this.search
          .toLowerCase())).sort((e, t) => this.sroles.indexOf(e.role) - this
          .sroles.indexOf(t.role))
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "admins":
            this.Admins = t.admins;
            break
        }
      })
    }
  },
  la = {
    class: "flex mx-5 w-full z-20"
  },
  ia = {
    class: "flex flex-col w-full"
  },
  na = {
    class: "flex flex-col mb-2"
  },
  aa = a("p", {
    class: "flex text-white mb-2 text-lg font-bold"
  }, "Serverio komanda", -1),
  ca = {
    class: "flex flex-row items-center justify-center w-60 px-4 py-2 rounded-md bg-slate-800 mb-2"
  },
  ua = a("i", {
    class: "fa-solid fa-magnifying-glass text-[#4EABF8] outline-none border-none mr-2"
  }, null, -1),
  da = {
    class: "flex flex-row justify-start flex-wrap overflow-y-auto w-full"
  },
  fa = ["onClick"],
  ha = {
    class: "flex flex-row mb-2"
  },
  pa = {
    class: "flex text-white text-lg"
  };

function ma(e, t, s, r, o, l) {
  const n = oe("admin");
  return T(), P(z, null, [S(a("div", la, [a("div", ia, [a("div", na, [aa, a(
    "div", ca, [ua, S(a("input", {
      class: "flex bg-transparent w-52 outline-none border-none text-white text-sm",
      "onUpdate:modelValue": t[0] || (t[0] = i => o
        .search = i),
      placeholder: "Įveskite komandos nario vardą"
    }, null, 512), [
      [_e, o.search]
    ])])]), a("div", da, [(T(!0), P(z, null, Ee(l.getAdmins,
    i => (T(), P("div", {
      class: "flex flex-col p-3 pr-0.5 bg-slate-800 rounded-md mr-3 mb-3 select-none hover:bg-slate-700",
      onClick: u => l.OpenWindow(i)
    }, [a("div", ha, [a("i", {
      class: Z([
        "fa-solid fa-circle py-1 mr-1 text-sm",
        i.online ? "text-lime-400" :
        "text-red-500"
      ])
    }, null, 2), a("p", pa, k(i.name), 1)]), a(
      "div", {
        class: "flex w-auto rounded-lg mr-2 px-2 py-0 leading-normal text-sm text-white",
        style: Le({
          background: o.roles[i.role].color
        })
      }, k(o.roles[i.role].name), 5)], 8, fa))), 256))])])], 512), [
    [D, s.show]
  ]), H(n, {
    show: o.dialog && s.show,
    admin: o.admin,
    onCloseDialog: t[1] || (t[1] = i => l.CloseDialog())
  }, null, 8, ["show", "admin"])], 64)
}
const xa = ue(ra, [
    ["render", ma]
  ]),
  ga = {
    props: {
      show: Boolean,
      heading: String,
      text: String
    }
  },
  ba = {
    class: "absolute flex h-full w-full items-center justify-center bg-black/80 backdrop-blur-sm"
  },
  _a = {
    class: "flex flex-col h-auto max-w-96 min-w-0 bg-slate-950 rounded-3xl p-8 overflow-auto space-y-2"
  },
  wa = {
    class: "text-white text-xl font-bold"
  },
  ya = {
    class: "text-white text-lg"
  },
  va = {
    class: "flex flex-row"
  };

function ka(e, t, s, r, o, l) {
  return S((T(), P("div", ba, [a("div", _a, [a("p", wa, k(s.heading), 1), a("p",
    ya, k(s.text), 1), a("div", va, [a("button", {
    class: "flex bg-green-600 text-white w-auto mr-2 p-2 rounded-lg border-2 border-transparent hover:bg-green-900 hover:border-green-600",
    onClick: t[0] || (t[0] = n => e.$emit("alertConfirm"))
  }, "Patvirtinti"), a("button", {
    class: "flex bg-red-600 text-white w-auto mr-2 p-2 rounded-lg border-2 border-transparent hover:bg-red-900 hover:border-red-600",
    onClick: t[1] || (t[1] = n => e.$emit("alertCancel"))
  }, "Atšaukti")])])], 512)), [
    [D, s.show]
  ])
}
const hs = ue(ga, [
    ["render", ka]
  ]),
  Aa = {
    props: {
      show: Boolean,
      player: Object,
      offline: Boolean
    },
    components: {
      AlertAdmin: hs
    },
    watch: {
      show(e) {
        e || (this.showAlert = !1)
      }
    },
    data() {
      return {
        showAlert: !1,
        alertText: "",
        alertHeading: "",
        alertAction: ""
      }
    },
    methods: {
      action(e) {
        e == "spectate" ? fe("spectate", {
          player: this.player.id
        }) : (console.log(e), this.showAlert = !1, fe("action", {
          action: e,
          player: this.player.id
        }))
      },
      alertShow(e, t, s) {
        this.showAlert = !0, this.alertHeading = e, this.alertText = t, this
          .alertAction = s
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "player-remove":
            t.player == this.player.id && ($emit("closeDialog"), this
              .showAlert = !1);
            break
        }
      })
    }
  },
  Ca = {
    class: "relative flex flex-col bg-slate-900/80 rounded-3xl z-10 w-1/2 h-full"
  },
  Ea = {
    class: "flex flex-col w-full p-10 h-full"
  },
  ja = {
    class: "flex w-full justify-end z-20"
  },
  Fa = {
    class: "flex text-white -mt-10 mb-2 text-xl font-bold"
  },
  Sa = {
    class: "flex flex-row"
  },
  Ta = a("i", {
    class: "fa-solid fa-location-crosshairs text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Oa = a("i", {
    class: "fa-solid fa-people-pulling text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Pa = a("i", {
    class: "fa-solid fa-eye text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  $a = a("i", {
    class: "fa-solid fa-person-walking-arrow-right text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Ia = us(
    '<p class="flex text-white mb-2 text-lg font-bold mt-5">Pataisos</p><div class="flex flex-row mb-2 justify-center"><p class="text-white mr-5 text-bold w-1/3">Administratorius</p><p class="text-white mr-5 text-bold w-1/3">Data</p><p class="text-white mr-5 text-bold w-1/3">Priežastis</p></div>',
    2),
  Ba = {
    class: "flex flex-col bg-slate-950 overflow-auto max-h-full w-full rounded-lg p-4"
  },
  Ma = {
    class: "flex flex-row mb-2"
  },
  Ra = {
    class: "text-white mr-2 w-1/3"
  },
  Da = {
    class: "text-white mr-2 w-1/3"
  },
  La = {
    class: "text-white mr-2 w-1/3"
  };

function Va(e, t, s, r, o, l) {
  const n = oe("AlertAdmin");
  return S((T(), P("div", Ca, [S(a("div", Ea, [a("div", ja, [a("i", {
      class: "fa-solid fa-xmark text-xl text-[#4EABF8] p-2",
      onClick: t[0] || (t[0] = i => e.$emit("closeDialog"))
    })]), a("p", Fa, k(s.player.name + " | " + s.player.id), 1),
    S(a("div", Sa, [a("button", {
      class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
      onClick: t[1] || (t[1] = i => l.alertShow(
        "Teleportuotis pas žaidėją",
        "Patvirtinkite, kad norite teleportuotis pas " +
        s.player.name + " žaidėją.", "teleport"))
    }, [Ta, M(" Teleportuotis")]), a("button", {
      class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
      onClick: t[2] || (t[2] = i => l.alertShow(
          "Atiteleportuoti žaidėją",
          "Patvirtinkite, kad norite atiteleportuoti " +
          s.player.name + " žaidėją pas save.", "bring"
          ))
    }, [Oa, M(" Atsiteleportuotis")]), a("button", {
      class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
      onClick: t[3] || (t[3] = i => l.action("spectate"))
    }, [Pa, M(" Stebėti")]), a("button", {
      class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
      onClick: t[4] || (t[4] = i => l.alertShow(
        "Išmesti žaidėją",
        "Patvirtinkite, kad norite išmesti " + s
        .player.name + " žaidėją.", "kick"))
    }, [$a, M(" Išmesti")])], 512), [
      [D, !s.offline]
    ]), Ia, a("div", Ba, [(T(!0), P(z, null, Ee(s.player.pataisos,
      i => (T(), P("div", Ma, [a("p", Ra, k(i.admin), 1),
        a("p", Da, k(i.given), 1), a("p", La, k(i
          .reason), 1)
      ]))), 256))])
  ], 512), [
    [D, s.show]
  ]), H(n, {
    show: o.showAlert,
    heading: o.alertHeading,
    text: o.alertText,
    onAlertConfirm: t[5] || (t[5] = i => l.action(o.alertAction)),
    onAlertCancel: t[6] || (t[6] = i => o.showAlert = !1)
  }, null, 8, ["show", "heading", "text"])], 512)), [
    [D, s.show]
  ])
}
const Gr = ue(Aa, [
    ["render", Va]
  ]),
  Na = {
    props: {
      show: Boolean
    },
    components: {
      info: Gr
    },
    data() {
      return {
        Players: {},
        search: "",
        player: {},
        dialog: !1
      }
    },
    watch: {
      show(e) {
        e || this.CloseDialog()
      }
    },
    methods: {
      OpenWindow(e) {
        this.dialog ? this.player = e : (this.dialog = !0, this.player = e)
      },
      CloseDialog() {
        this.dialog = !1
      }
    },
    computed: {
      getPlayers() {
        var t;
        const e = (t = this.search) == null ? void 0 : t.toLowerCase().trim();
        return e ? Object.values(this.Players).filter(s => {
          var l, n;
          const r = ((l = s.name) == null ? void 0 : l.toLowerCase()) || "",
            o = ((n = s.id) == null ? void 0 : n.toString()) || "";
          return r.includes(e) || o.includes(e)
        }) : Object.values(this.Players)
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "online":
            this.Players = t.players;
            break;
          case "player-update":
            t.player.id == this.player.id && (this.player = t.player);
            break
        }
      })
    }
  },
  Ha = {
    class: "flex mx-5 w-full z-20"
  },
  Ua = {
    class: "flex flex-col w-full"
  },
  Ka = {
    class: "flex flex-col h-10 mb-12"
  },
  za = a("p", {
    class: "flex text-white mb-2 text-lg font-bold"
  }, "Aktyvūs žaidėjai", -1),
  Wa = {
    class: "flex flex-row items-center justify-center w-60 px-4 py-2 rounded-md bg-slate-800"
  },
  qa = a("i", {
    class: "fa-solid fa-magnifying-glass text-[#4EABF8] outline-none border-none mr-2"
  }, null, -1),
  Ga = {
    class: "flex flex-row justify-start flex-wrap overflow-y-auto w-full"
  },
  Ja = ["onClick"],
  Ya = a("i", {
    class: "flex fa-solid fa-user py-1 mr-3 text-[#4EABF8]"
  }, null, -1),
  Xa = ["textContent"];

function Za(e, t, s, r, o, l) {
  const n = oe("info");
  return T(), P(z, null, [S(a("div", Ha, [a("div", Ua, [a("div", Ka, [za, a(
    "div", Wa, [qa, S(a("input", {
      class: "flex bg-transparent w-52 outline-none border-none text-white text-sm",
      "onUpdate:modelValue": t[0] || (t[0] = i => o
        .search = i),
      placeholder: "Įveskite žaidėjo ID/Vardą"
    }, null, 512), [
      [_e, o.search]
    ])])]), a("div", Ga, [(T(!0), P(z, null, Ee(l.getPlayers, (
    i, u) => (T(), P("div", {
    key: u,
    class: "flex h-10 px-4 py-2 bg-slate-800 text-white rounded-md mr-3 mb-3 select-none hover:bg-slate-700",
    onClick: f => l.OpenWindow(i)
  }, [Ya, a("a", {
    class: "flex text-white",
    textContent: k(i.id + " | " + i.name)
  }, null, 8, Xa)], 8, Ja))), 128))])])], 512), [
    [D, s.show]
  ]), H(n, {
    show: o.dialog,
    player: o.player,
    onCloseDialog: t[1] || (t[1] = i => l.CloseDialog())
  }, null, 8, ["show", "player"])], 64)
}
const Qa = ue(Na, [
    ["render", Za]
  ]),
  ec = {
    props: {
      show: Boolean
    },
    components: {
      info: Gr
    },
    data() {
      return {
        Players: {},
        search: "",
        player: {},
        dialog: !1
      }
    },
    watch: {
      show(e) {
        e || this.CloseDialog()
      }
    },
    methods: {
      OpenWindow(e) {
        this.dialog ? this.player = e : (this.dialog = !0, this.player = e)
      },
      CloseDialog() {
        this.dialog = !1
      }
    },
    computed: {
      getPlayers() {
        var t;
        const e = (t = this.search) == null ? void 0 : t.toLowerCase().trim();
        return e ? Object.values(this.Players).filter(s => {
          var l, n;
          const r = ((l = s.name) == null ? void 0 : l.toLowerCase()) || "",
            o = ((n = s.id) == null ? void 0 : n.toString()) || "";
          return r.includes(e) || o.includes(e)
        }) : Object.values(this.Players)
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "offline":
            this.Players = t.players;
            break
        }
      })
    }
  },
  tc = {
    class: "flex mx-5 w-full z-20"
  },
  sc = {
    class: "flex flex-col w-full"
  },
  oc = {
    class: "flex flex-col h-10 mb-12"
  },
  rc = a("p", {
    class: "flex text-white mb-2 text-lg font-bold"
  }, "Atsijungę žaidėjai", -1),
  lc = {
    class: "flex flex-row items-center justify-center w-60 px-4 py-2 rounded-md bg-slate-800"
  },
  ic = a("i", {
    class: "fa-solid fa-magnifying-glass text-[#4EABF8] outline-none border-none mr-2"
  }, null, -1),
  nc = {
    class: "flex flex-row justify-start flex-wrap overflow-y-auto w-full"
  },
  ac = ["onClick"],
  cc = a("i", {
    class: "flex fa-solid fa-user py-1 mr-3 text-[#4EABF8]"
  }, null, -1),
  uc = ["textContent"];

function dc(e, t, s, r, o, l) {
  const n = oe("info");
  return T(), P(z, null, [S(a("div", tc, [a("div", sc, [a("div", oc, [rc, a(
    "div", lc, [ic, S(a("input", {
      class: "flex bg-transparent w-52 outline-none border-none text-white text-sm",
      "onUpdate:modelValue": t[0] || (t[0] = i => o
        .search = i),
      placeholder: "Įveskite žaidėjo ID/Vardą"
    }, null, 512), [
      [_e, o.search]
    ])])]), a("div", nc, [(T(!0), P(z, null, Ee(l.getPlayers, (
    i, u) => (T(), P("div", {
    key: u,
    class: "flex h-10 px-4 py-2 bg-slate-800 text-white rounded-md mr-3 mb-3 select-none hover:bg-slate-700",
    onClick: f => l.OpenWindow(i)
  }, [cc, a("a", {
    class: "flex text-white",
    textContent: k(i.id + " | " + i.name)
  }, null, 8, uc)], 8, ac))), 128))])])], 512), [
    [D, s.show]
  ]), H(n, {
    show: o.dialog && s.show,
    player: o.player,
    offline: !0,
    onCloseDialog: t[1] || (t[1] = i => l.CloseDialog())
  }, null, 8, ["show", "player"])], 64)
}
const fc = ue(ec, [
    ["render", dc]
  ]),
  hc = {
    props: {
      show: Boolean,
      report: Object
    },
    components: {
      AlertAdmin: hs
    },
    data() {
      return {
        roles: {
          owner: {
            color: "#F1C40F",
            name: "Savininkas"
          },
          dev: {
            color: "#0064C4",
            name: "Developeris"
          },
          pagradmin: {
            color: "#F50202",
            name: "Pagr. Administratorius(-ė)"
          },
          vyradmin: {
            color: "#E91E63",
            name: "Vyr. Administratorius(-ė)"
          },
          admin: {
            color: "#AC0303",
            name: "Administratorius(-ė)"
          },
          vyrsupport: {
            color: "#9B59B6",
            name: "Vyr. Support"
          },
          support: {
            color: "#FE3586",
            name: "Support"
          },          
          player: {
            color: "#3A4750",
            name: "Žaidėjas"
          }
        },
        links: ["https://medal.tv", "https://youtu.be",
          "https://streamable.com", "https://www.youtube.com/"
        ],
        message: "",
        showAlert: !1,
        alertHeading: "",
        alertText: "",
        alertAction: "",
        categories: {
          bugs: "Klaidos",
          player: "Žaidėjai",
          questions: "Klausimai"
        }
      }
    },
    watch: {
      show(e) {
        e && (setTimeout(() => {
          this.scrollToReason()
        }, 1500), setTimeout(() => {
          this.scrollToChat()
        }, 1e3)), e || (this.showAlert = !1)
      },
      report() {
        setTimeout(() => {
          this.scrollToReason()
        }, 1500), setTimeout(() => {
          this.scrollToChat()
        }, 1e3)
      }
    },
    methods: {
      scrollToChat() {
        var e;
        (e = this.$refs.chatDiv) == null || e.scrollIntoView({
          behavior: "auto"
        })
      },
      scrollToReason() {
        var e;
        (e = this.$refs.reasonDiv) == null || e.scrollIntoView({
          behavior: "auto"
        })
      },
      checkIsEmbed(e) {
        for (let t = 0; t < this.links.length; t++)
          if (e.includes(this.links[t])) return !0;
        return !1
      },
      returnLink(e) {
        return e.includes("medal.tv") ? (e = e.replace("/gta-v", ""), e = e
          .replace("/games", ""), e = e.replace("clips", "clip"), console.log(
            e), e) : e.includes("youtu.be") ? (e = e.replace(
          "https://youtu.be/", "https://www.youtube.com/embed/"), e) : (e
          .includes("streamable.com") && (e = e.replace(
            "https://streamable.com/", "https://streamable.com/e/")), e)
      },
      sendMessage() {
        this.message.length >= 1 && (fe("sendMessage", {
          id: this.report.id,
          message: this.message
        }), this.message = "")
      },
      action(e) {
        e == "spectate" ? fe("spectate", {
          player: this.report.player.id
        }) : (console.log("report", e), this.showAlert = !1, fe("action", {
          action: e,
          player: this.report.player.id,
          report: this.report.id
        }))
      },
      OpenVideo(e) {
        this.checkIsEmbed(e) && window.invokeNative("openUrl", e)
      },
      alertShow(e, t, s) {
        this.showAlert = !0, this.alertHeading = e, this.alertText = t, this
          .alertAction = s
      }
    },
    mounted() {
      setTimeout(() => {
        this.scrollToChat()
      }, 1200), setTimeout(() => {
        this.scrollToReason()
      }, 1e3), window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "update-chat":
            this.show && this.report.id == t.id && (this.report.chat = t
              .chat);
            break;
          case "remove-report":
            this.show && this.report.id == t.id && (this.$emit(
              "closeDialog"), this.showAlert = !1);
            break
        }
      })
    }
  },
  pc = {
    class: "relative flex flex-col bg-slate-900/80 rounded-3xl z-10 w-1/2"
  },
  mc = {
    class: "flex flex-col w-full p-10 h-full"
  },
  xc = {
    class: "flex w-full justify-end z-20"
  },
  gc = {
    class: "flex text-white -mt-10 mb-2 text-xl font-bold"
  },
  bc = {
    class: "font-normal ml-5"
  },
  _c = {
    class: "flex flex-row flex-wrap"
  },
  wc = a("i", {
    class: "fa-solid fa-location-crosshairs text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  yc = a("i", {
    class: "fa-solid fa-people-pulling text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  vc = a("i", {
    class: "fa-solid fa-eye text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  kc = a("i", {
    class: "fa-solid fa-person-walking-arrow-right text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Ac = a("i", {
    class: "fa-solid fa-clipboard-check text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Cc = a("i", {
    class: "fa-solid fa-lock text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Ec = a("i", {
    class: "fa-solid fa-clipboard-check text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  jc = {
    class: "overflow-auto"
  },
  Fc = a("p", {
    class: "flex text-white mb-2 text-lg font-bold mt-2"
  }, "Užklausos priežastis", -1),
  Sc = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  Tc = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Žaidėjo ID/Nickname", -1),
  Oc = ["value"],
  Pc = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Žaidėjo pažeistos taisyklės", -1),
  $c = {
    placeholder: "Aprašykite žaidėjo pažeistas taisykles",
    class: "flex bg-slate-950 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-2",
    disabled: ""
  },
  Ic = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite situaciją", -1),
  Bc = {
    placeholder: "Aprašykite situaciją kurioje žaidėjas pažeidė taisykles, taip pat galite pateikti įrodymų nuorodą (medal.tv, streamable.com, youtube.com)",
    class: "flex bg-slate-950 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4",
    disabled: ""
  },
  Mc = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  Rc = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite klaidą", -1),
  Dc = {
    placeholder: "Aprašykite klaidą su kuria susidūrėte, taip pat galite pateikti įrodymų nuorodą (medal.tv, streamable.com, youtube.com)",
    class: "flex bg-slate-950 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4",
    disabled: ""
  },
  Lc = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  Vc = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite kuo galime jums padėti", -1),
  Nc = {
    placeholder: "Aprašykite kuo galime jums padėti, taip pat galite pateikti vaizdinės medžiagos nuorodą (medal.tv, streamable.com, youtube.com) jeigu klausimas to reikalauja",
    class: "flex bg-slate-950 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4",
    disabled: ""
  },
  Hc = a("p", {
    class: "flex text-white mb-2 text-lg font-bold mt-5"
  }, "Pokalbis", -1),
  Uc = {
    class: "flex flex-col scroll-smooth bg-slate-950 overflow-auto h-72 w-full rounded-lg p-4 mb-2",
    ref: "scrollBottom"
  },
  Kc = {
    class: "flex flex-row flex-wrap mb-2"
  },
  zc = {
    class: "text-[#4EABF8] mr-2"
  },
  Wc = ["onClick"],
  qc = {
    ref: "chatDiv"
  },
  Gc = {
    class: "flex flex-row items-center justify-start w-full px-4 py-2 rounded-md bg-slate-950"
  },
  Jc = a("i", {
    class: "fa-solid fa-paper-plane text-[#4EABF8] mr-4"
  }, null, -1);

function Yc(e, t, s, r, o, l) {
  var i, u;
  const n = oe("AlertAdmin");
  return S((T(), P("div", pc, [S(a("div", mc, [a("div", xc, [a("i", {
    class: "fa-solid fa-xmark text-xl text-[#4EABF8] p-2",
    onClick: t[0] || (t[0] = f => e.$emit("closeDialog"))
  })]), a("p", gc, [M(k(((i = s.report.player) == null ?
    void 0 : i.name) + " | " + ((u = s.report.player) ==
    null ? void 0 : u.id)) + " ", 1), a("a", bc, k(o
    .categories[s.report.category]), 1)]), a("div", _c, [a(
    "button", {
      class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2",
      onClick: t[1] || (t[1] = f => l.alertShow(
        "Teleportuotis pas žaidėją",
        "Patvirtinkite, kad norite teleportuotis pas " +
        s.report.player.name + " žaidėją.", "teleport"))
    }, [wc, M(" Teleportuotis")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2",
    onClick: t[2] || (t[2] = f => l.alertShow(
      "Atiteleportuoti žaidėją",
      "Patvirtinkite, kad norite atiteleportuoti " + s
      .report.player.name + " žaidėją pas save.",
      "bring"))
  }, [yc, M(" Atiteleportuotis")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2",
    onClick: t[3] || (t[3] = f => l.action("spectate"))
  }, [vc, M(" Stebėti")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2",
    onClick: t[4] || (t[4] = f => l.alertShow(
      "Išmesti žaidėją",
      "Patvirtinkite, kad norite išmesti " + s.report
      .player.name + " žaidėją.", "kick"))
  }, [kc, M(" Išmesti")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2",
    onClick: t[5] || (t[5] = f => l.action("claim"))
  }, [Ac, M(" Priimti")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2",
    onClick: t[6] || (t[6] = f => l.alertShow(
      "Uždaryti užklausą",
      "Patvirtinkite, kad užklausa nebėra reikalinga ir ją galima uždaryti.",
      "close"))
  }, [Cc, M(" Uždaryti")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2",
    onClick: t[7] || (t[7] = f => l.alertShow(
      "Išspręsti užklausą",
      "Patvirtinkite, kad atlikote visus reikiamus veiksmus ir padėjote žaidėjui ir esate įsitikinęs, kad jam pagalba daugiau nebėra reikalinga.",
      "solve"))
  }, [Ec, M(" Išspręsti")])]), a("div", jc, [Fc, S(a("div", Sc,
    [Tc, a("input", {
      placeholder: "Įveskite žaidėjo ID/Nickname",
      class: "flex bg-slate-950 text-white p-3 resize-none w-full text-sm rounded-lg outline-none mb-2",
      disabled: "",
      value: s.report.rplayer
    }, null, 8, Oc), Pc, a("textarea", $c, k(s.report
      .rules), 1), Ic, a("textarea", Bc, k(s.report
      .description), 1)], 512), [
    [D, s.report.category == "player"]
  ]), S(a("div", Mc, [Rc, a("textarea", Dc, k(s.report
    .description), 1)], 512), [
    [D, s.report.category == "bugs"]
  ]), S(a("div", Lc, [Vc, a("textarea", Nc, k(s.report
    .description), 1)], 512), [
    [D, s.report.category == "questions"]
  ]), Hc, a("div", Uc, [(T(!0), P(z, null, Ee(s.report.chat,
    f => (T(), P("div", Kc, [a("p", zc, k(f.user),
      1), f.role ? (T(), P("div", {
      key: 0,
      class: "flex flex-row w-auto rounded-lg mr-2 px-2 py-0 leading-normal text-sm text-white",
      style: Le({
        background: o.roles[f.role]
          .color
      })
    }, k(o.roles[f.role].name), 5)) : tt("", !
      0), a("p", {
      class: "text-white",
      onClick: p => l.OpenVideo(f.message)
    }, k(f.message), 9, Wc)]))), 256)), a("div", qc,
    null, 512)], 512), a("div", Gc, [Jc, S(a("input", {
    class: "flex bg-transparent w-full outline-none border-none text-white text-sm",
    "onUpdate:modelValue": t[8] || (t[8] = f => o
      .message = f),
    placeholder: "Išsiųskite žinutę žaidėjui...",
    onKeyup: t[9] || (t[9] = qr(f => l
    .sendMessage(), ["enter"]))
  }, null, 544), [
    [_e, o.message]
  ])])])], 512), [
    [D, s.show]
  ]), H(n, {
    show: o.showAlert,
    heading: o.alertHeading,
    text: o.alertText,
    onAlertConfirm: t[10] || (t[10] = f => l.action(o.alertAction)),
    onAlertCancel: t[11] || (t[11] = f => o.showAlert = !1)
  }, null, 8, ["show", "heading", "text"])], 512)), [
    [D, s.show]
  ])
}
const Xc = ue(hc, [
    ["render", Yc]
  ]),
  Zc = {
    props: {
      show: Boolean
    },
    components: {
      report: Xc
    },
    data() {
      return {
        Reports: {},
        report: {},
        dialog: !1,
        categories: {
          bugs: "Klaidos",
          player: "Žaidėjai",
          questions: "Klausimai"
        }
      }
    },
    watch: {
      show(e) {
        e || this.CloseDialog()
      }
    },
    methods: {
      OpenWindow(e) {
        this.dialog ? this.report = e : (this.dialog = !0, this.report = e)
      },
      CloseDialog() {
        this.dialog = !1
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "reports":
            const s = o => {
                const [l, n, i] = o.split(":").map(u => parseInt(u, 10));
                return l * 3600 + n * 60 + i
              },
              r = Object.entries(t.reports);
            r.sort(([, o], [, l]) => s(o.time) - s(l.time)), this.Reports =
              r.map(([, o]) => o);
            break
        }
      })
    }
  },
  Qc = {
    class: "flex mx-5 w-full"
  },
  eu = {
    class: "flex flex-col w-full"
  },
  tu = us(
    '<div class="flex flex-col h-10 mb-2"><p class="flex text-white mb-2 text-xl font-bold">Aktyvios užklausos</p></div><div class="flex flex-row mb-4"><p class="text-white mr-2 text-bold w-[14%] text-center">Laikas</p><p class="text-white mr-2 text-bold w-[14%] text-center">Žaidėjas</p><p class="text-white mr-2 text-bold w-[14%] text-center">Priežastis</p><p class="text-white mr-2 text-bold w-[14%] text-center">Kategorija</p><p class="text-white mr-2 text-bold w-[14%] text-center">Administratorius</p><p class="text-white mr-2 text-bold w-[14%] text-center">Statusas</p><p class="text-white mr-2 text-bold w-[14%] text-center"></p></div>',
    2),
  su = {
    class: "flex flex-col justify-start items-start w-full resize-none overflow-auto"
  },
  ou = {
    class: "text-white mr-2 w-[14%] text-center"
  },
  ru = {
    class: "text-white mr-2 w-[14%] text-center text-clip overflow-hidden h-6"
  },
  lu = {
    class: "text-white mr-2 w-[14%] text-clip overflow-hidden h-6 text-center"
  },
  iu = {
    class: "text-white mr-2 w-[14%] text-center"
  },
  nu = {
    class: "text-white mr-2 w-[14%] text-center"
  },
  au = {
    class: "text-white mr-2 w-[14%] text-center"
  },
  cu = ["onClick"],
  uu = a("i", {
    class: "fa-solid fa-square-up-right text-[#4EABF8] text-xl"
  }, null, -1),
  du = [uu];

function fu(e, t, s, r, o, l) {
  const n = oe("report");
  return T(), P(z, null, [S(a("div", Qc, [a("div", eu, [tu, a("div", su, [(T(!
    0), P(z, null, Ee(o.Reports, (i, u) => (T(), P("div", {
      key: u,
      class: "flex flex-row mb-2 w-full pb-2.5 pt-3 rounded-lg border-none bg-slate-900"
    }, [a("p", ou, k(i.time), 1), a("p", ru, k(i
      .player.name), 1), a("p", lu, k(i
      .category == "player" && i.rules || i
      .description), 1), a("p", iu, k(o
      .categories[i.category]), 1), a("p", nu, k(i
      .admin), 1), a("p", au, [a("i", {
      class: Z(["fa-solid fa-circle mr-1", i
        .status ? "text-lime-500" :
        "text-red-500"
      ])
    }, null, 2), M(" " + k(i.status ?
      "Priimtas" : "Nepriimtas"), 1)]), a("p", {
      class: "text-white mr-2 text-bold w-[14%] text-center",
      onClick: f => l.OpenWindow(i)
    }, du, 8, cu)]))), 128))])])], 512), [
    [D, s.show]
  ]), H(n, {
    show: o.dialog && s.show,
    report: o.report,
    onCloseDialog: t[0] || (t[0] = i => l.CloseDialog())
  }, null, 8, ["show", "report"])], 64)
}
const hu = ue(Zc, [
    ["render", fu]
  ]),
  pu = {
    components: {
      alert: hs
    },
    data() {
      return {
        show: !1,
        alert: {
          show: !1,
          heading: "Ar tikrai norite uždaryti savo užklausą?",
          text: "Uždarius užklausą administratoriai jos nebematys, tačiau jūs vistiek galėsite matyti užklausos istoriją report meniu."
        },
        ophistory: !1,
        player: {
          name: "s1m1s",
          id: 1
        },
        created: !1,
        category: "",
        sreport: {},
        history: [],
        shistory: {},
        roles: {
          owner: {
            color: "#F1C40F",
            name: "Savininkas"
          },
          dev: {
            color: "#0064C4",
            name: "Developeris"
          },
          pagradmin: {
            color: "#F50202",
            name: "Pagr. Administratorius(-ė)"
          },
          vyradmin: {
            color: "#E91E63",
            name: "Vyr. Administratorius(-ė)"
          },
          admin: {
            color: "#AC0303",
            name: "Administratorius(-ė)"
          },
          vyrsupport: {
            color: "#9B59B6",
            name: "Vyr. Support"
          },
          support: {
            color: "#FE3586",
            name: "Support"
          },
          player: {
            color: "#3A4750",
            name: "Žaidėjas"
          }
        },
        links: ["https://medal.tv", "https://youtu.be",
          "https://streamable.com", "https://www.youtube.com/"
        ],
        message: "",
        rplayer: "",
        description: "",
        rules: "",
        canopen: !1
      }
    },
    watch: {
      show() {
        setTimeout(() => {
          this.scrollToChat()
        }, 1e3)
      },
      sreport() {
        setTimeout(() => {
          this.scrollToChat()
        }, 1e3)
      }
    },
    methods: {
      scrollToChat() {
        var e;
        (e = this.$refs.chatDiv) == null || e.scrollIntoView({
          behavior: "auto"
        })
      },
      CloseMenu() {
        fe("closeself")
      },
      SubmitReport() {
        this.category == "player" ? this.description.length >= 10 && this.rules
          .length >= 3 && this.rplayer.length >= 1 && this.canopen && this
          .checkIsEmbed(this.description) && fe("submitReport", {
            category: this.category,
            rplayer: this.rplayer,
            description: this.description,
            rules: this.rules
          }) : (this.category == "bugs" || this.category == "questions") && this
          .description.length >= 10 && fe("submitReport", {
            category: this.category,
            rplayer: this.rplayer,
            description: this.description,
            rules: this.rules
          })
      },
      CloseReport() {
        fe("closereport", {
          id: this.sreport.id
        })
      },
      sendMessage() {
        this.message.length >= 1 && (fe("sendMessage", {
          id: this.sreport.id,
          message: this.message
        }), this.message = "")
      },
      checkIsEmbed(e) {
        for (let t = 0; t < this.links.length; t++)
          if (e.includes(this.links[t])) return !0;
        return !1
      },
      OpenHistory(e) {
        this.ophistory = !0, this.history[e].index = e, this.shistory = this
          .history[e]
      },
      CloseHistory() {
        this.ophistory = !1, this.history[this.shistory.index].index = null,
          this.shistory = {}
      },
      AlertOpen() {
        this.alert.show = !0
      },
      AlertYes() {
        this.alert.show = !1, this.CloseReport()
      },
      AlertNo() {
        this.alert.show = !1
      },
      OpenVideo(e) {
        this.checkIsEmbed(e) && window.invokeNative("openUrl", e)
      }
    },
    mounted() {
      setTimeout(() => {
        this.scrollToChat()
      }, 1200), window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "show-self-report":
            this.show = t.show;
            break;
          case "update-self-player":
            this.player.name = t.name, this.player.id = t.id;
            break;
          case "update-self-chat":
            this.sreport.chat = t.chat;
            break;
          case "close-self":
            this.created = !1, this.category = "";
            break;
          case "udpate-history":
            this.history = t.history;
            break;
          case "created-report":
            this.created = !0, this.sreport = t.report;
            break
        }
      }), document.addEventListener("keydown", e => {
        e.key === "Escape" && this.show && this.CloseMenu()
      })
    }
  },
  mu = {
    class: "flex h-screen w-screen items-center justify-center"
  },
  xu = {
    class: "relative flex flex-row max-h-[80%] w-5/12 bg-slate-950 rounded-3xl p-8 overflow-auto"
  },
  gu = {
    class: "flex flex-col w-60 p-10 overflow-auto"
  },
  bu = ["onClick"],
  _u = {
    key: 0,
    class: "flex flex-col w-full p-10"
  },
  wu = {
    class: "flex w-full justify-end z-20"
  },
  yu = {
    class: "flex flex-col w-full h-full p-10"
  },
  vu = {
    class: "flex text-white -mt-10 mb-2 text-xl font-bold"
  },
  ku = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  Au = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Žaidėjo ID/Nickname", -1),
  Cu = ["value"],
  Eu = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Žaidėjo pažeistos taisyklės", -1),
  ju = {
    placeholder: "Aprašykite žaidėjo pažeistas taisykles",
    class: "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-2",
    disabled: ""
  },
  Fu = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite situaciją", -1),
  Su = {
    placeholder: "Aprašykite situaciją kurioje žaidėjas pažeidė taisykles, taip pat galite pateikti įrodymų nuorodą (medal.tv, streamable.com, youtube.com)",
    class: "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4",
    disabled: ""
  },
  Tu = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  Ou = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite klaidą", -1),
  Pu = {
    placeholder: "Aprašykite klaidą su kuria susidūrėte, taip pat galite pateikti įrodymų nuorodą (medal.tv, streamable.com, youtube.com)",
    class: "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4",
    disabled: ""
  },
  $u = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  Iu = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite kuo galime jums padėti", -1),
  Bu = {
    placeholder: "Aprašykite kuo galime jums padėti, taip pat galite pateikti vaizdinės medžiagos nuorodą (medal.tv, streamable.com, youtube.com) jeigu klausimas to reikalauja",
    class: "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4",
    disabled: ""
  },
  Mu = a("p", {
    class: "flex text-white mb-2 text-lg font-bold mt-5 w-full"
  }, "Pokalbis", -1),
  Ru = {
    class: "flex flex-col scroll-smooth bg-slate-900 overflow-auto max-h-80 w-full rounded-lg p-4 mb-2"
  },
  Du = {
    class: "flex flex-row flex-wrap mb-2"
  },
  Lu = {
    class: "text-[#4EABF8] mr-2"
  },
  Vu = {
    class: "text-white"
  },
  Nu = ["onClick"],
  Hu = {
    ref: "chatDiv"
  },
  Uu = {
    key: 1,
    class: "flex flex-col w-full p-12"
  },
  Ku = {
    class: "flex text-white -mt-10 mb-2 text-xl font-bold"
  },
  zu = {
    class: "flex flex-row mb-4"
  },
  Wu = a("i", {
    class: "fa-solid fa-user text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  qu = a("i", {
    class: "fa-solid fa-server text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Gu = a("i", {
    class: "fa-solid fa-question text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Ju = {
    class: "text-white text-md"
  },
  Yu = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  Xu = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Žaidėjo ID/Nickname", -1),
  Zu = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Žaidėjo pažeistos taisyklės", -1),
  Qu = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite situaciją bei pateikite įrodymų nuorodą", -1),
  ed = {
    class: "flex flex-col mb-4"
  },
  td = {
    class: "flex flex-row justify-start items-center"
  },
  sd = a("p", {
      class: "flex font-small text-gray-500 text-sm mt-1"
    },
    "* Jeigu neturite įrodymų iš situacijos ir pažymėjote šį laukelį, jūsų užklausa bus uždaryta ir jūs būsite nubaustas atitinkama bausme. P.s įrodymai pareikiami situacijos aprašyme.",
    -1),
  od = {
    class: "flex flex-row"
  },
  rd = a("i", {
    class: "fa-solid fa-share text-[#4EABF8] mr-2 ml-1"
  }, null, -1),
  ld = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  id = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite klaidą", -1),
  nd = {
    class: "flex flex-row"
  },
  ad = a("i", {
    class: "fa-solid fa-share text-[#4EABF8] mr-2 ml-1"
  }, null, -1),
  cd = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  ud = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, [M("Aprašykite kuo galime jums padėti "), a("a", {
    class: "ml-2 text-red-500"
  }, "Ši kategorija nėra skirta pranešti apie taisyklių pažeidimus")], -1),
  dd = a("p", {
      class: "flex font-small text-gray-500 text-sm mb-4"
    },
    "* Jei aprašyme yra nurodomi taisyklių pažeidimai, tai bus laikoma netinkamu reporto užpildymu. Administratorius turi teisę uždaryti tokį reportą, o pakartotinis netinkamas kategorijos pasirinkimas su ta pačia priežastimi gali lemti nuobaudą.",
    -1),
  fd = {
    class: "flex flex-row"
  },
  hd = a("i", {
    class: "fa-solid fa-share text-[#4EABF8] mr-2 ml-1"
  }, null, -1),
  pd = {
    key: 2,
    class: "flex flex-col w-full h-full p-10"
  },
  md = {
    class: "flex text-white -mt-10 mb-2 text-xl font-bold"
  },
  xd = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  gd = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Žaidėjo ID/Nickname", -1),
  bd = ["value"],
  _d = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Žaidėjo pažeistos taisyklės", -1),
  wd = {
    placeholder: "Aprašykite žaidėjo pažeistas taisykles",
    class: "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-2",
    disabled: ""
  },
  yd = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite situaciją", -1),
  vd = {
    placeholder: "Aprašykite situaciją kurioje žaidėjas pažeidė taisykles, taip pat galite pateikti įrodymų nuorodą (medal.tv, streamable.com, youtube.com)",
    class: "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4",
    disabled: ""
  },
  kd = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  Ad = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite klaidą", -1),
  Cd = {
    placeholder: "Aprašykite klaidą su kuria susidūrėte, taip pat galite pateikti įrodymų nuorodą (medal.tv, streamable.com, youtube.com)",
    class: "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4",
    disabled: ""
  },
  Ed = {
    class: "flex flex-col w-full overflow-auto justify-center items-center"
  },
  jd = a("p", {
    class: "flex text-white text-md mb-2 text-left w-full"
  }, "Aprašykite kuo galime jums padėti", -1),
  Fd = {
    placeholder: "Aprašykite kuo galime jums padėti, taip pat galite pateikti vaizdinės medžiagos nuorodą (medal.tv, streamable.com, youtube.com) jeigu klausimas to reikalauja",
    class: "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4",
    disabled: ""
  },
  Sd = a("p", {
    class: "flex text-white mb-2 text-lg font-bold mt-5 w-full"
  }, "Pokalbis", -1),
  Td = {
    class: "flex flex-col scroll-smooth bg-slate-900 overflow-auto max-h-80 w-full rounded-lg p-4 mb-2"
  },
  Od = {
    class: "flex flex-row flex-wrap mb-2"
  },
  Pd = {
    class: "text-[#4EABF8] mr-2"
  },
  $d = ["onClick"],
  Id = {
    ref: "chatDiv"
  },
  Bd = {
    class: "flex flex-row items-center justify-start w-full px-4 py-2 rounded-md bg-slate-900 mb-4"
  },
  Md = a("i", {
    class: "fa-solid fa-paper-plane text-[#4EABF8] mr-4"
  }, null, -1),
  Rd = {
    class: "flex flex-row"
  },
  Dd = a("i", {
    class: "fa-solid fa-lock text-[#4EABF8] mr-2 ml-1"
  }, null, -1);

function Ld(e, t, s, r, o, l) {
  const n = oe("alert");
  return S((T(), P("div", mu, [a("div", xu, [!o.created && o.history.length >
    0 ? (T(), P(z, {
      key: 0
    }, [a("div", gu, [(T(!0), P(z, null, Ee(o.history, (i, u) =>
        (T(), P("p", {
          class: Z([
            "flex w-full rounded-lg p-2 py-2 text-white mr-2 border-2 hover:border-[#48759F] bg-slate-900 mb-2",
            o.shistory.index == u ?
            "border-[#48759F]" :
            "border-transparent"
          ]),
          onClick: f => l.OpenHistory(u)
        }, k("Užklausa #" + (u + 1)), 11, bu))), 256))]), o
      .ophistory ? (T(), P("div", _u, [a("div", wu, [a("i", {
        class: "fa-solid fa-xmark text-xl text-[#4EABF8] p-2",
        onClick: t[0] || (t[0] = i => l
          .CloseHistory())
      })]), a("div", yu, [a("p", vu, k("Užklausa #" + (o
        .shistory.index + 1)), 1), S(a("div", ku, [Au,
        a("input", {
          placeholder: "Įveskite žaidėjo ID/Nickname",
          class: "flex bg-slate-900 text-white p-3 resize-none w-full text-sm rounded-lg outline-none mb-2",
          disabled: "",
          value: o.shistory.rplayer
        }, null, 8, Cu), Eu, a("textarea", ju, k(o
          .shistory.rules), 1), Fu, a("textarea",
          Su, k(o.shistory.description), 1)
      ], 512), [
        [D, o.shistory.category == "player"]
      ]), S(a("div", Tu, [Ou, a("textarea", Pu, k(o
        .shistory.description), 1)], 512), [
        [D, o.shistory.category == "bugs"]
      ]), S(a("div", $u, [Iu, a("textarea", Bu, k(o
        .shistory.description), 1)], 512), [
        [D, o.shistory.category == "questions"]
      ]), Mu, a("div", Ru, [(T(!0), P(z, null, Ee(o
        .shistory.chat, i => (T(), P("div",
          Du, [a("p", Lu, k(i.user), 1), i
            .role ? (T(), P("div", {
                key: 0,
                class: "flex flex-row w-auto rounded-lg mr-2 px-2 py-0 leading-normal text-sm text-white",
                style: Le({
                  background: o.roles[
                    i.role].color
                })
              }, k(o.roles[i.role].name),
              5)) : tt("", !0), a("p", Vu,
              k(i.message), 1), a("p", {
              class: "text-white",
              onClick: u => l.OpenVideo(i
                .message)
            }, k(i.message), 9, Nu)
          ]))), 256)), a("div", Hu, null, 512)])])])) : tt("", !
        0)
    ], 64)) : tt("", !0), !o.created && !o.ophistory ? (T(), P(
      "div", Uu, [a("p", Ku, k(o.player.name + " | " + o.player
        .id), 1), a("div", zu, [a("button", {
        class: "rounded-lg bg-slate-900 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
        onClick: t[1] || (t[1] = i => o.category =
          "player")
      }, [Wu, M(" Pranešti apie žaidėją")]), a("button", {
        class: "rounded-lg bg-slate-900 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
        onClick: t[2] || (t[2] = i => o.category = "bugs")
      }, [qu, M(" Serverio klaidos")]), a("button", {
        class: "rounded-lg bg-slate-900 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
        onClick: t[3] || (t[3] = i => o.category =
          "questions")
      }, [Gu, M(" Bendri klausimai")])]), S(a("p", Ju,
        "Prieš sukurdami užklausą turite pasirinkti vieną iš kategorijų, ją pasirinkus reikės užpildyti tam tikrą formą kurią gaus serverio komanda, tad prašome užpildyti viską kuo išsamiau.",
        512), [
        [D, o.category == ""]
      ]), S(a("div", Yu, [Xu, S(a("input", {
        placeholder: "Įveskite žaidėjo ID/Nickname",
        class: Z([
          "flex bg-slate-900 text-white p-3 resize-none w-full text-sm rounded-lg outline-none mb-2 border-2",
          o.rplayer.length < 1 ?
          "border-red-500" : "border-transparent"
        ]),
        "onUpdate:modelValue": t[4] || (t[4] = i => o
          .rplayer = i)
      }, null, 2), [
        [_e, o.rplayer]
      ]), Zu, S(a("textarea", {
        placeholder: "Aprašykite žaidėjo pažeistas taisykles",
        class: Z([
          "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-2 border-2",
          o.rules.length < 3 ? "border-red-500" :
          "border-transparent"
        ]),
        "onUpdate:modelValue": t[5] || (t[5] = i => o
          .rules = i)
      }, null, 2), [
        [_e, o.rules]
      ]), Qu, S(a("textarea", {
        placeholder: "Aprašykite situaciją kurioje žaidėjas pažeidė taisykles, taip pat privalote pateikti įrodymų nuorodą (medal.tv, streamable.com, youtube.com)",
        class: Z([
          "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4 border-2",
          o.description.length < 10 || !l
          .checkIsEmbed(o.description) ?
          "border-red-500" : "border-transparent"
        ]),
        "onUpdate:modelValue": t[6] || (t[6] = i => o
          .description = i)
      }, null, 2), [
        [_e, o.description]
      ]), a("div", ed, [a("div", td, [S(a("input", {
          type: "checkbox",
          id: "clip",
          class: "w-4 h-4 text-[#4EABF8] rounded border-2 bg-white border-white",
          "onUpdate:modelValue": t[7] || (t[7] =
            i => o.canopen = i)
        }, null, 512), [
          [zr, o.canopen]
        ]), a("label", {
          for: "clip",
          class: Z(["ms-2 text-sm font-medium", o
            .canopen ? "text-white" :
            "text-red-500"
          ])
        }, "Turiu įrodymus iš šios situacijos", 2)]),
        sd]), a("div", od, [a("button", {
        class: "rounded-lg bg-slate-700 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
        onClick: t[8] || (t[8] = i => l
          .SubmitReport())
      }, [rd, M(" Pateikti")])])], 512), [
        [D, o.category == "player"]
      ]), S(a("div", ld, [id, S(a("textarea", {
        placeholder: "Aprašykite klaidą su kuria susidūrėte, taip pat galite pateikti įrodymų nuorodą (medal.tv, streamable.com, youtube.com)",
        class: Z([
          "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-4 border-2",
          o.description.length < 10 ?
          "border-red-500" : "border-transparent"
        ]),
        "onUpdate:modelValue": t[9] || (t[9] = i => o
          .description = i)
      }, null, 2), [
        [_e, o.description]
      ]), a("div", nd, [a("button", {
        class: "rounded-lg bg-slate-700 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
        onClick: t[10] || (t[10] = i => l
          .SubmitReport())
      }, [ad, M(" Pateikti")])])], 512), [
        [D, o.category == "bugs"]
      ]), S(a("div", cd, [ud, S(a("textarea", {
        placeholder: "Aprašykite kuo galime jums padėti, taip pat galite pateikti vaizdinės medžiagos nuorodą (medal.tv, streamable.com, youtube.com) jeigu klausimas to reikalauja",
        class: Z([
          "flex bg-slate-900 text-white p-3 resize-none w-full h-72 text-sm rounded-lg outline-none mb-2 border-2",
          o.description.length < 10 ?
          "border-red-500" : "border-transparent"
        ]),
        "onUpdate:modelValue": t[11] || (t[11] = i =>
          o.description = i)
      }, null, 2), [
        [_e, o.description]
      ]), dd, a("div", fd, [a("button", {
        class: "rounded-lg bg-slate-700 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
        onClick: t[12] || (t[12] = i => l
          .SubmitReport())
      }, [hd, M(" Pateikti")])])], 512), [
        [D, o.category == "questions"]
      ])])) : tt("", !0), o.created ? (T(), P("div", pd, [a("p", md,
      k(o.player.name + " | " + o.player.id), 1), S(a("div",
      xd, [gd, a("input", {
        placeholder: "Įveskite žaidėjo ID/Nickname",
        class: "flex bg-slate-900 text-white p-3 resize-none w-full text-sm rounded-lg outline-none mb-2",
        disabled: "",
        value: o.sreport.rplayer
      }, null, 8, bd), _d, a("textarea", wd, k(o.sreport
        .rules), 1), yd, a("textarea", vd, k(o.sreport
        .description), 1)], 512), [
      [D, o.sreport.category == "player"]
    ]), S(a("div", kd, [Ad, a("textarea", Cd, k(o.sreport
      .description), 1)], 512), [
      [D, o.sreport.category == "bugs"]
    ]), S(a("div", Ed, [jd, a("textarea", Fd, k(o.sreport
      .description), 1)], 512), [
      [D, o.sreport.category == "questions"]
    ]), Sd, a("div", Td, [(T(!0), P(z, null, Ee(o.sreport
      .chat, i => (T(), P("div", Od, [a("p", Pd, k(i
        .user), 1), i.role ? (T(), P("div", {
        key: 0,
        class: "flex flex-row w-auto rounded-lg mr-2 px-2 py-0 leading-normal text-sm text-white",
        style: Le({
          background: o.roles[i.role]
            .color
        })
      }, k(o.roles[i.role].name), 5)) : tt("", !
        0), a("p", {
        class: "text-white",
        onClick: u => l.OpenVideo(i.message)
      }, k(i.message), 9, $d)]))), 256)), a("div", Id,
      null, 512)]), a("div", Bd, [Md, S(a("input", {
      class: "flex bg-transparent w-full outline-none border-none text-white text-sm",
      "onUpdate:modelValue": t[13] || (t[13] = i => o
        .message = i),
      placeholder: "Išsiųskite žinutę serverio komandai...",
      onKeyup: t[14] || (t[14] = qr(i => l
        .sendMessage(), ["enter"]))
    }, null, 544), [
      [_e, o.message]
    ])]), a("div", Rd, [a("button", {
      class: "rounded-lg bg-slate-700 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F]",
      onClick: t[15] || (t[15] = i => l.AlertOpen())
    }, [Dd, M(" Uždaryti užklausą")])])])) : tt("", !0), H(n, {
      show: o.alert.show,
      heading: o.alert.heading,
      text: o.alert.text,
      onAlertConfirm: t[16] || (t[16] = i => l.AlertYes()),
      onAlertCancel: t[17] || (t[17] = i => l.AlertNo())
    }, null, 8, ["show", "heading", "text"])
  ])], 512)), [
    [D, o.show]
  ])
}
const Vd = ue(pu, [
    ["render", Ld]
  ]),
  Nd = {
    props: {
      disable: Boolean
    },
    data() {
      return {
        show: !1,
        text: ""
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "text-ui":
            this.show = t.show, t.text && (this.text = t.text);
            break
        }
      })
    }
  },
  Hd = {
    class: "flex h-screen w-screen items-end justify-center z-0"
  },
  Ud = {
    class: "flex flex-row bg-slate-950 rounded-lg justify-center items-center p-4 pb-0 mb-4"
  },
  Kd = ["innerHTML"];

function zd(e, t, s, r, o, l) {
  return S((T(), P("div", Hd, [a("div", Ud, [a("p", {
    class: "text-white text-lg mb-4",
    innerHTML: o.text
  }, null, 8, Kd)])], 512)), [
    [D, o.show && !s.disable]
  ])
}
const Wd = ue(Nd, [
    ["render", zd]
  ]),
  qd = {
    props: {
      show: Boolean
    },
    data() {
      return {
        roles: {
          owner: {
            color: "#F1C40F",
            name: "Savininkas"
          },
          dev: {
            color: "#0064C4",
            name: "Developeris"
          },
          pagradmin: {
            color: "#F50202",
            name: "Pagr. Administratorius(-ė)"
          },
          vyradmin: {
            color: "#E91E63",
            name: "Vyr. Administratorius(-ė)"
          },
          admin: {
            color: "#AC0303",
            name: "Administratorius(-ė)"
          },
          vyrsupport: {
            color: "#9B59B6",
            name: "Vyr. Support"
          },
          support: {
            color: "#FE3586",
            name: "Support"
          },
          player: {
            color: "#3A4750",
            name: "Žaidėjas"
          }
        },
        Admins: []
      }
    },
    methods: {
      getHours(e) {
        let t = Math.floor(e / 60 / 60),
          s = Math.floor(e / 60 - t * 60);
        return t + "h " + s + "min"
      }
    },
    computed: {
      getAdmins() {
        return this.Admins.sort((e, t) => e.reports30 > t.reports30 || e
          .reports30 == t.reports30 && e.time30 > t.time30 ? -1 : 0)
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "admins":
            this.Admins = t.admins;
            break
        }
      })
    }
  },
  Gd = {
    class: "flex mx-5 w-full"
  },
  Jd = {
    class: "flex flex-col w-full"
  },
  Yd = us(
    '<div class="flex flex-col h-10 mb-2"><p class="flex text-white mb-2 text-xl font-bold">Lyderių lentelė</p></div><div class="flex flex-row mb-4"><p class="text-white mr-2 text-bold w-2 text-center">Vieta</p><p class="text-white mr-2 text-bold w-1/5 text-center">Administratorius</p><p class="text-white mr-2 text-bold w-1/5 text-center">Rolė</p><p class="text-white mr-2 text-bold w-1/5 text-center">Atsakytos užklausos</p><p class="text-white mr-2 text-bold w-1/5 text-center">Išspręstos užklausos</p><p class="text-white mr-2 text-bold w-1/5 text-center">Aktyvumas</p></div>',
    2),
  Xd = {
    class: "flex flex-col justify-start items-start w-full resize-none overflow-auto"
  },
  Zd = {
    class: "flex flex-row mb-2 w-full pb-2.5 pt-3 rounded-lg border-none bg-slate-900"
  },
  Qd = {
    class: "text-white ml-4 mr-2 w-2 text-left"
  },
  ef = {
    class: "text-white mr-2 w-1/5 text-center"
  },
  tf = {
    class: "flex flex-row mr-2 w-1/5 items-center justify-center"
  },
  sf = {
    class: "text-white mr-2 w-1/5 text-center"
  },
  of = {
    class: "text-white mr-2 w-1/5 text-clip overflow-hidden h-6 text-center"
  },
  rf = {
    class: "text-white mr-2 w-1/5 text-center"
  };

function lf(e, t, s, r, o, l) {
  return S((T(), P("div", Gd, [a("div", Jd, [Yd, a("div", Xd, [(T(!0), P(z,
    null, Ee(l.getAdmins, (n, i) => (T(), P("div", Zd, [a(
        "p", Qd, k(i + 1 + "."), 1), a("p", ef, k(n
        .name), 1), a("div", tf, [a("div", {
        class: "flex w-auto rounded-lg px-2 py-0 leading-normal text-sm text-white",
        style: Le({
          background: o.roles[n.role].color
        })
      }, k(o.roles[n.role].name), 5)]), a("p", sf, k(n
        .reports30), 1), a("p", of, k(n.claimed30),
      1), a("p", rf, k(l.getHours(n.time30)), 1)
    ]))), 256))])])], 512)), [
    [D, s.show]
  ])
}
const nf = ue(qd, [
    ["render", lf]
  ]),
  af = {
    props: {
      show: Boolean,
      heading: String,
      text: String,
      type: String,
      placeholder: String
    },
    data() {
      return {
        input: ""
      }
    }
  },
  cf = {
    class: "absolute flex h-full w-full items-center justify-center bg-black/60 backdrop-blur-sm"
  },
  uf = {
    class: "flex flex-col h-auto w-auto bg-slate-950 rounded-3xl p-8 space-y-3 overflow-auto items-center"
  },
  df = {
    class: "text-white text-xl font-bold"
  },
  ff = {
    class: "text-white text-lg"
  },
  hf = {
    class: "flex flex-row"
  },
  pf = ["type", "placeholder"],
  mf = {
    class: "flex flex-row"
  };

function xf(e, t, s, r, o, l) {
  return S((T(), P("div", cf, [a("div", uf, [a("p", df, k(s.heading), 1), a("p",
    ff, k(s.text), 1), a("div", hf, [S(a("input", {
    type: s.type,
    placeholder: s.placeholder,
    "onUpdate:modelValue": t[0] || (t[0] = n => o.input =
      n),
    class: "bg-slate-800 p-2 rounded-lg outline-none text-white"
  }, null, 8, pf), [
    [_n, o.input]
  ])]), a("div", mf, [a("button", {
    class: "flex bg-green-600 text-white w-auto mr-2 p-2 rounded-lg border-2 border-transparent hover:bg-green-900 hover:border-green-600",
    onClick: t[1] || (t[1] = n => e.$emit("inputSave", o
      .input))
  }, "Patvirtinti"), a("button", {
    class: "flex bg-red-600 text-white w-auto mr-2 p-2 rounded-lg border-2 border-transparent hover:bg-red-900 hover:border-red-600",
    onClick: t[2] || (t[2] = n => e.$emit("inputClose"))
  }, "Atšaukti")])])], 512)), [
    [D, s.show]
  ])
}
const gf = ue(af, [
    ["render", xf]
  ]),
  bf = {
    props: {
      show: Boolean,
      pataisos: Object
    },
    components: {
      Input: gf,
      AlertAdmin: hs
    },
    watch: {
      show(e) {
        e || (this.showAlert = !1, this.inputShow = !1)
      }
    },
    data() {
      return {
        inputShow: !1,
        showAlert: !1,
        alertText: "",
        alertHeading: "",
        alertAction: ""
      }
    },
    methods: {
      action(e) {
        e == "spectate" ? fe("spectate", {
          player: this.pataisos.id
        }) : (this.showAlert = !1, fe("action", {
          action: e,
          player: this.pataisos.id
        }))
      },
      openInput() {
        this.inputShow = !0
      },
      changeTime(e) {
        this.inputShow = !1, fe("action", {
          action: "pataisosTime",
          player: this.pataisos.id,
          jobs: e
        })
      },
      alertShow(e, t, s) {
        this.showAlert = !0, this.alertHeading = e, this.alertText = t, this
          .alertAction = s
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "pataisos-remove":
            console.log(this.show, t.player, this.pataisos.id), this.show &&
              t.player == this.pataisos.id && (this.$emit("closeDialog"),
                this.inputShow = !1);
            break
        }
      })
    }
  },
  _f = {
    class: "flex flex-col bg-slate-900/80 rounded-3xl z-10 w-1/2 relative"
  },
  wf = {
    class: "flex flex-col w-full p-10 h-full"
  },
  yf = {
    class: "flex w-full justify-end z-20"
  },
  vf = {
    class: "flex text-white -mt-10 mb-2 text-xl font-bold"
  },
  kf = {
    class: "flex flex-row flex-wrap"
  },
  Af = a("i", {
    class: "fa-solid fa-location-crosshairs text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Cf = a("i", {
    class: "fa-solid fa-people-pulling text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Ef = a("i", {
    class: "fa-solid fa-eye text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  jf = a("i", {
    class: "fa-solid fa-person-walking-arrow-right text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Ff = a("i", {
    class: "fa-solid fa-person-digging text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Sf = a("i", {
    class: "fa-solid fa-eraser text-[#4EABF8] mr-1 ml-1"
  }, null, -1),
  Tf = a("p", {
    class: "text-white mb-2 text-md"
  }, "Pataisų priežastis", -1),
  Of = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  },
  Pf = a("p", {
    class: "text-white mb-2 text-md"
  }, "Likęs darbų skaičius", -1),
  $f = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  },
  If = a("p", {
    class: "text-white mb-2 text-md"
  }, "Nubaudė", -1),
  Bf = {
    class: "flex w-full items-center rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 border-2 border-transparent hover:border-[#48759F] mb-2"
  };

function Mf(e, t, s, r, o, l) {
  const n = oe("Input"),
    i = oe("AlertAdmin");
  return S((T(), P("div", _f, [S(a("div", wf, [a("div", yf, [a("i", {
    class: "fa-solid fa-xmark text-xl text-[#4EABF8] p-2",
    onClick: t[0] || (t[0] = u => e.$emit("closeDialog"))
  })]), a("p", vf, k(s.pataisos.name + " | " + s.pataisos.id),
    1), a("div", kf, [a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 mb-2 border-2 border-transparent hover:border-[#48759F]",
    onClick: t[1] || (t[1] = u => l.alertShow(
      "Teleportuotis pas žaidėją",
      "Patvirtinkite, kad norite teleportuotis pas " +
      s.pataisos.name + " žaidėją.", "teleport"))
  }, [Af, M(" Teleportuotis")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 mb-2 border-2 border-transparent hover:border-[#48759F]",
    onClick: t[2] || (t[2] = u => l.alertShow(
      "Atiteleportuoti žaidėją",
      "Patvirtinkite, kad norite atiteleportuoti " + s
      .pataisos.name + " žaidėją pas save.", "bring"))
  }, [Cf, M(" Atsiteleportuotis")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 mb-2 border-2 border-transparent hover:border-[#48759F]",
    onClick: t[3] || (t[3] = u => l.action("spectate"))
  }, [Ef, M(" Stebėti")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 mb-2 border-2 border-transparent hover:border-[#48759F]",
    onClick: t[4] || (t[4] = u => l.alertShow(
      "Išmesti žaidėją",
      "Patvirtinkite, kad norite išmesti " + s
      .pataisos.name + " žaidėją.", "kick"))
  }, [jf, M(" Išmesti")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 mb-2 border-2 border-transparent hover:border-[#48759F]",
    onClick: t[5] || (t[5] = u => l.openInput())
  }, [Ff, M(" Koreguoti pataisas")]), a("button", {
    class: "rounded-lg bg-slate-950 p-2 py-2 text-white mr-2 mb-2 border-2 border-transparent hover:border-[#48759F]",
    onClick: t[6] || (t[6] = u => l.alertShow(
      "Nuimti pataisas",
      "Patvirtinkite, kad tikrai norite nuimti pataisas " +
      s.pataisos.name + " žaidėjui.", "pataisosRemove"
      ))
  }, [Sf, M(" Nuimti pataisas")])]), Tf, a("div", Of, k(s
    .pataisos.reason), 1), Pf, a("div", $f, k(s.pataisos.jobs),
    1), If, a("div", Bf, k(s.pataisos.admin), 1)], 512), [
    [D, s.show]
  ]), H(n, {
    show: o.inputShow,
    heading: "Pakeisti darbų skaičių",
    text: s.pataisos.name + " šiuo metu turi " + s.pataisos.jobs +
      " darbų",
    type: "number",
    placeholder: "Darbų skaičius...",
    onInputSave: l.changeTime,
    onInputClose: t[7] || (t[7] = u => o.inputShow = !1)
  }, null, 8, ["show", "text", "onInputSave"]), H(i, {
    show: o.showAlert,
    heading: o.alertHeading,
    text: o.alertText,
    onAlertConfirm: t[8] || (t[8] = u => l.action(o.alertAction)),
    onAlertCancel: t[9] || (t[9] = u => o.showAlert = !1)
  }, null, 8, ["show", "heading", "text"])], 512)), [
    [D, s.show]
  ])
}
const Rf = ue(bf, [
    ["render", Mf]
  ]),
  Df = {
    props: {
      show: Boolean
    },
    components: {
      ppataisos: Rf
    },
    data() {
      return {
        Pataisos: {},
        player: {},
        dialog: !1
      }
    },
    watch: {
      show(e) {
        e || this.CloseDialog()
      }
    },
    methods: {
      OpenWindow(e, t) {
        this.dialog ? this.player = e : (this.dialog = !0, this.player = e)
      },
      CloseDialog() {
        this.dialog = !1
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "pataisos":
            this.Pataisos = t.pataisos;
            break;
          case "pataisos-update":
            this.dialog && t.player.id == this.player.id && (this.player = t
              .player);
            break
        }
      })
    }
  },
  Lf = {
    class: "flex relative mx-5 w-full"
  },
  Vf = {
    class: "flex flex-col w-full"
  },
  Nf = us(
    '<div class="flex flex-col h-10 mb-2"><p class="flex text-white mb-2 text-xl font-bold">Šiuo metu pataisų turintys žaidėjai</p></div><div class="flex flex-row mb-4"><p class="text-white mr-2 text-bold w-1/5 text-center">Žaidėjas</p><p class="text-white mr-2 text-bold w-1/5 text-center">Likę Darbai</p><p class="text-white mr-2 text-bold w-1/5 text-center">Priežastis</p><p class="text-white mr-2 text-bold w-1/5 text-center">Administratorius</p><p class="text-white mr-2 text-bold w-1/5 text-center"></p></div>',
    2),
  Hf = {
    class: "flex flex-col justify-start items-start w-full resize-none overflow-auto"
  },
  Uf = {
    class: "text-white mr-2 w-1/5 text-center"
  },
  Kf = {
    class: "text-white mr-2 w-1/5 text-center"
  },
  zf = {
    class: "text-white mr-2 w-1/5 text-clip overflow-hidden h-6 text-center"
  },
  Wf = {
    class: "text-white mr-2 w-1/5 text-center"
  },
  qf = ["onClick"],
  Gf = a("i", {
    class: "fa-solid fa-square-up-right text-[#4EABF8] text-xl"
  }, null, -1),
  Jf = [Gf];

function Yf(e, t, s, r, o, l) {
  const n = oe("ppataisos");
  return T(), P(z, null, [S(a("div", Lf, [a("div", Vf, [Nf, a("div", Hf, [(T(!
    0), P(z, null, Ee(o.Pataisos, (i, u) => (T(), P("div", {
      key: u,
      class: "flex flex-row mb-2 w-full pb-2.5 pt-3 rounded-lg border-none bg-slate-900"
    }, [a("p", Uf, k(i.name), 1), a("p", Kf, k(i
      .jobs), 1), a("p", zf, k(i.reason), 1), a(
      "p", Wf, k(i.admin), 1), a("p", {
      class: "text-white mr-2 text-bold w-1/5 text-center",
      onClick: f => l.OpenWindow(i, u)
    }, Jf, 8, qf)]))), 128))])])], 512), [
    [D, s.show]
  ]), H(n, {
    show: o.dialog && s.show,
    pataisos: o.player,
    onCloseDialog: t[0] || (t[0] = i => l.CloseDialog())
  }, null, 8, ["show", "pataisos"])], 64)
}
const Xf = ue(Df, [
    ["render", Yf]
  ]),
  Zf = {
    components: {
      admins: xa,
      players: Qa,
      offline: fc,
      reports: hu,
      preport: Vd,
      textui: Wd,
      leaderboard: nf,
      pataisos: Xf
    },
    data() {
      return {
        menu: "players",
        show: !1,
        superAdmin: !1,
        restricted: {
          leaderboard: !0
        }
      }
    },
    methods: {
      CloseMenu() {
        fe("close")
      },
      Category(e) {
        this.restricted[e] ? this.superAdmin && (this.menu = e) : this.menu = e
      }
    },
    mounted() {
      window.addEventListener("message", e => {
        const t = e.data;
        switch (t.type) {
          case "menu":
            this.show = t.show;
            break;
          case "issuper":
            this.superAdmin = t.super;
            break
        }
      }), document.addEventListener("keydown", e => {
        e.key === "Escape" && this.show && this.CloseMenu()
      })
    }
  },
  Qf = {
    class: "flex h-screen w-screen items-center justify-center z-10"
  },
  eh = {
    class: "flex flex-row h-4/5 w-10/12 bg-slate-950 rounded-3xl p-8"
  },
  th = {
    class: "flex flex-col w-12"
  },
  sh = a("i", {
    class: "fa-solid fa-people-group"
  }, null, -1),
  oh = [sh],
  rh = a("i", {
    class: "fa-solid fa-user-plus"
  }, null, -1),
  lh = [rh],
  ih = a("i", {
    class: "fa-solid fa-user-xmark"
  }, null, -1),
  nh = [ih],
  ah = a("i", {
    class: "fa-solid fa-flag"
  }, null, -1),
  ch = [ah],
  uh = a("i", {
    class: "fa-solid fa-broom"
  }, null, -1),
  dh = [uh];

function fh(e, t, s, r, o, l) {
  const n = oe("admins"),
    i = oe("players"),
    u = oe("offline"),
    f = oe("reports"),
    p = oe("leaderboard"),
    y = oe("pataisos"),
    C = oe("preport"),
    $ = oe("textui");
  return T(), P(z, null, [S(a("div", Qf, [a("div", eh, [a("div", th, [a("div", {
    class: Z([
      "flex justify-center p-4 py-4 text-[#4EABF8] rounded-md mb-2 border-2 hover:border-[#48759F]",
      o.menu == "leaderboard" ?
      "bg-slate-800 border-[#48759F]" :
      "bg-slate-950 border-transparent"
    ]),
    onClick: t[0] || (t[0] = K => l.Category(
      "leaderboard"))
  }, [a("i", {
    class: Z(["fa-solid fa-chess-queen", o
      .superAdmin ? "opacity-100" : "opacity-50"
    ])
  }, null, 2)], 2), a("div", {
    class: Z([
      "flex justify-center p-4 py-4 text-[#4EABF8] rounded-md mb-2 border-2 hover:border-[#48759F]",
      o.menu == "admins" ?
      "bg-slate-800 border-[#48759F]" :
      "bg-slate-950 border-transparent"
    ]),
    onClick: t[1] || (t[1] = K => l.Category("admins"))
  }, oh, 2), a("div", {
    class: Z([
      "flex justify-center p-4 py-4 text-[#4EABF8] rounded-md mb-2 border-2 hover:border-[#48759F]",
      o.menu == "players" ?
      "bg-slate-800 border-[#48759F]" :
      "bg-slate-950 border-transparent"
    ]),
    onClick: t[2] || (t[2] = K => l.Category("players"))
  }, lh, 2), a("div", {
    class: Z([
      "flex justify-center p-4 py-4 text-[#4EABF8] rounded-md mb-2 border-2 hover:border-[#48759F]",
      o.menu == "offline" ?
      "bg-slate-800 border-[#48759F]" :
      "bg-slate-950 border-transparent"
    ]),
    onClick: t[3] || (t[3] = K => l.Category("offline"))
  }, nh, 2), a("div", {
    class: Z([
      "flex justify-center p-4 py-4 text-[#4EABF8] rounded-md mb-2 border-2 hover:border-[#48759F]",
      o.menu == "reports" ?
      "bg-slate-800 border-[#48759F]" :
      "bg-slate-950 border-transparent"
    ]),
    onClick: t[4] || (t[4] = K => l.Category("reports"))
  }, ch, 2), a("div", {
    class: Z([
      "flex justify-center p-4 py-4 text-[#4EABF8] rounded-md mb-2 border-2 hover:border-[#48759F]",
      o.menu == "pataisos" ?
      "bg-slate-800 border-[#48759F]" :
      "bg-slate-950 border-transparent"
    ]),
    onClick: t[5] || (t[5] = K => l.Category("pataisos"))
  }, dh, 2)]), H(n, {
    show: o.menu == "admins"
  }, null, 8, ["show"]), H(i, {
    show: o.menu == "players"
  }, null, 8, ["show"]), H(u, {
    show: o.menu == "offline"
  }, null, 8, ["show"]), H(f, {
    show: o.menu == "reports"
  }, null, 8, ["show"]), H(p, {
    show: o.menu == "leaderboard"
  }, null, 8, ["show"]), H(y, {
    show: o.menu == "pataisos"
  }, null, 8, ["show"])])], 512), [
    [D, o.show]
  ]), H(C), H($, {
    disable: o.show
  }, null, 8, ["disable"])], 64)
}
const hh = ue(Zf, [
  ["render", fh]
]);
An(hh).mount("#app");

window.addEventListener('message', function(event) {
  if (event.data.type === 'pataisos') {
    const players = event.data.players;
    const tableBody = document.getElementById('pataisos-table-body');
    if (!tableBody) return;
    tableBody.innerHTML = '';
    Object.values(players).forEach(player => {
      const row = document.createElement('tr');
      row.innerHTML = `
        <td>${player.name}</td>
        <td>${player.minutes}</td>
        <td>${player.reason}</td>
        <td>${player.admin}</td>
      `;
      tableBody.appendChild(row);
    });
  }
});