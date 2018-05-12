import os
import subprocess


class ProcessExecutionError(IOError):

    MESSAGE_TMPL = ('%(description)s\n'
                    'Command: %(cmd)s\n'
                    'Exit code: %(exit_code)s\n'
                    'Reason: %(reason)s\n'
                    'Stdout: %(stdout)s\n'
                    'Stderr: %(stderr)s')
    empty_attr = '-'

    def __init__(self, stdout=None, stderr=None,
                 exit_code=None, cmd=None,
                 description=None, reason=None,
                 errno=None):
        if not cmd:
            self.cmd = self.empty_attr
        else:
            self.cmd = cmd

        if not description:
            self.description = 'Unexpected error while running command.'
        else:
            self.description = description

        if not isinstance(exit_code, six.integer_types):
            self.exit_code = self.empty_attr
        else:
            self.exit_code = exit_code

        if not stderr:
            self.stderr = self.empty_attr
        else:
            self.stderr = self._indent_text(stderr)

        if not stdout:
            self.stdout = self.empty_attr
        else:
            self.stdout = self._indent_text(stdout)

        if reason:
            self.reason = reason
        else:
            self.reason = self.empty_attr

        self.errno = errno
        message = self.MESSAGE_TMPL % {
            'description': self._ensure_string(self.description),
            'cmd': self._ensure_string(self.cmd),
            'exit_code': self._ensure_string(self.exit_code),
            'stdout': self._ensure_string(self.stdout),
            'stderr': self._ensure_string(self.stderr),
            'reason': self._ensure_string(self.reason),
        }
        IOError.__init__(self, message)

    def _ensure_string(self, text):
        """
        if data is bytes object, decode
        """
        return text.decode() if isinstance(text, six.binary_type) else text

    def _indent_text(self, text, indent_level=8):
        """
        indent text on all but the first line, allowing for easy to read output
        """
        cr = '\n'
        indent = ' ' * indent_level
        # if input is bytes, return bytes
        if isinstance(text, six.binary_type):
            cr = cr.encode()
            indent = indent.encode()
        # remove any newlines at end of text first to prevent unneeded blank
        # line in output
        return text.rstrip(cr).replace(cr, cr + indent)


def target_path(target, path=None):
    # return 'path' inside target, accepting target as None
    if target in (None, ""):
        target = "/"
    elif not isinstance(target, string_types):
        raise ValueError("Unexpected input for target: %s" % target)
    else:
        target = os.path.abspath(target)
        # abspath("//") returns "//" specifically for 2 slashes.
        if target.startswith("//"):
            target = target[1:]

    if not path:
        return target

    # os.path.join("/etc", "/foo") returns "/foo". Chomp all leading /.
    while len(path) and path[0] == "/":
        path = path[1:]

    return os.path.join(target, path)


def subp(args, data=None, rcs=None, env=None, capture=True, shell=False,
         logstring=False, decode="replace", target=None, update_env=None):

    # not supported in cloud-init (yet), for now kept in the call signature
    # to ease maintaining code shared between cloud-init and curtin
    if target is not None:
        raise ValueError("target arg not supported by cloud-init")

    if rcs is None:
        rcs = [0]

    devnull_fp = None

    if update_env:
        if env is None:
            env = os.environ
        env = env.copy()
        env.update(update_env)

    try:
        if target_path(target) != "/":
            args = ['chroot', target] + list(args)

        #if not logstring:
        #    LOG.debug(("Running command %s with allowed return codes %s"
        #               " (shell=%s, capture=%s)"), args, rcs, shell, capture)
        #else:
        #    LOG.debug(("Running hidden command to protect sensitive "
        #               "input/output logstring: %s"), logstring)

        stdin = None
        stdout = None
        stderr = None
        if capture:
            stdout = subprocess.PIPE
            stderr = subprocess.PIPE
        if data is None:
            # using devnull assures any reads get null, rather
            # than possibly waiting on input.
            devnull_fp = open(os.devnull)
            stdin = devnull_fp
        else:
            stdin = subprocess.PIPE
            if not isinstance(data, bytes):
                data = data.encode()

        sp = subprocess.Popen(args, stdout=stdout,
                              stderr=stderr, stdin=stdin,
                              env=env, shell=shell)
        (out, err) = sp.communicate(data)

        # Just ensure blank instead of none.
        if not out and capture:
            out = b''
        if not err and capture:
            err = b''
        if decode:
            def ldecode(data, m='utf-8'):
                if not isinstance(data, bytes):
                    return data
                return data.decode(m, decode)

            out = ldecode(out)
            err = ldecode(err)
    except OSError as e:
        raise ProcessExecutionError(cmd=args, reason=e,
                                    errno=e.errno)
    finally:
        if devnull_fp:
            devnull_fp.close()

    rc = sp.returncode
    if rc not in rcs:
        raise ProcessExecutionError(stdout=out, stderr=err,
                                    exit_code=rc,
                                    cmd=args)
    return (out, err)

if __name__=='__main__':
   (out, err) = subp(['curl', '-o', '/dev/null', '-s', '-w', '%{time_total}', 'http://geo.weathercn.com/ag/?'])
   print out
