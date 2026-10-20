<?php

namespace App\Http\Controllers;

use App\Dispatch\Coordinator;
use App\Models\AuditEntry;
use App\Models\DeliveryTask;
use App\Models\NotificationEvent;
use App\Models\Provider;
use App\Models\RequestStep;
use Illuminate\Http\Request;

class ConsoleController extends Controller
{
    public function dashboard()
    {
        return view('dashboard', [
            'counts' => ['events' => NotificationEvent::count(), 'active' => RequestStep::whereIn('status', ['ready', 'running', 'retry', 'waiting'])->count(),
                'success' => RequestStep::where('status', 'succeeded')->count(), 'attention' => RequestStep::whereIn('status', ['dead', 'unknown', 'blocked'])->count()],
            'events' => NotificationEvent::withCount('tasks')->latest()->limit(8)->get(), 'providers' => Provider::all(),
            'recentFailures' => RequestStep::with('task.event')->whereIn('status', ['dead', 'unknown'])->latest()->limit(5)->get(),
        ]);
    }

    public function events(Request $r)
    {
        $q = NotificationEvent::withCount('tasks')->latest();
        if ($r->filled('q')) {
            $q->where(fn ($q) => $q->where('id', 'like', '%'.$r->string('q').'%')->orWhere('external_id', 'like', '%'.$r->string('q').'%')->orWhere('source', 'like', '%'.$r->string('q').'%'));
        }
        if ($r->filled('status')) {
            $q->where('conversion_status', $r->string('status'));
        }

        return view('events.index', ['events' => $q->paginate(25)->withQueryString()]);
    }

    public function event(string $id)
    {
        $event = NotificationEvent::with(['tasks.steps.attempts', 'version.workflow'])->findOrFail($id);
        $previous = $event->predecessor_id !== null ? NotificationEvent::where('source', $event->source)->where('external_id', $event->predecessor_id)->first() : null;
        $children = NotificationEvent::where('source', $event->source)->where('predecessor_id', $event->external_id)->get();

        return view('events.show', compact('event', 'previous', 'children') + ['summary' => app(Coordinator::class)->summary($event)]);
    }

    public function tasks(Request $r)
    {
        $q = DeliveryTask::with('event')->withCount('steps')->latest();
        if ($r->filled('q')) {
            $q->where(fn ($q) => $q->where('id', 'like', '%'.$r->string('q').'%')->orWhere('name', 'like', '%'.$r->string('q').'%')->orWhereHas('event', fn ($e) => $e->where(fn ($identity) => $identity->where('external_id', 'like', '%'.$r->string('q').'%')->orWhere('source', 'like', '%'.$r->string('q').'%'))));
        }
        if ($r->filled('status')) {
            $q->where('status', $r->string('status'));
        }

        return view('tasks', ['tasks' => $q->paginate(25)->withQueryString()]);
    }

    public function requests(Request $r)
    {
        $q = RequestStep::with(['task.event', 'provider'])->withCount('attempts')->latest();
        if ($r->filled('q')) {
            $q->where(fn ($q) => $q->where('id', 'like', '%'.$r->string('q').'%')->orWhere('name', 'like', '%'.$r->string('q').'%')->orWhereHas('task.event', fn ($e) => $e->where(fn ($identity) => $identity->where('external_id', 'like', '%'.$r->string('q').'%')->orWhere('source', 'like', '%'.$r->string('q').'%'))));
        }
        if ($r->filled('status')) {
            $q->where('status', $r->string('status'));
        }
        if ($r->filled('provider')) {
            $q->where('provider_id', $r->string('provider'));
        }

        return view('requests.index', ['steps' => $q->paginate(25)->withQueryString(), 'providers' => Provider::all(), 'dead' => false]);
    }

    public function step(string $id)
    {
        return view('requests.show', ['step' => RequestStep::with(['attempts', 'task.event', 'provider'])->findOrFail($id)]);
    }

    public function dead()
    {
        return view('requests.index', ['steps' => RequestStep::with(['task.event', 'provider'])->withCount('attempts')->whereIn('status', ['dead', 'unknown', 'blocked'])->latest()->paginate(25),
            'providers' => Provider::all(), 'dead' => true, 'failedEvents' => NotificationEvent::where('conversion_status', 'failed')->latest()->limit(50)->get()]);
    }

    public function audit()
    {
        return view('audit', ['entries' => AuditEntry::latest()->paginate(30)]);
    }
}
